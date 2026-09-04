import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/core/utils/extensions/ext_widget.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';

class MeasurementsList extends StatelessWidget {
  final List<MeasurementsListItem> dataList;
  final bool displayAccordion;
  final String? accordionHeader;

  const MeasurementsList({
    required this.dataList,
    this.displayAccordion = false,
    this.accordionHeader,
    super.key,
  }) : assert(
         !displayAccordion || accordionHeader != null,
         "If displayAccordion is true, an accordionHeader value must be not null.",
       );

  @override
  Widget build(BuildContext context) {
    final accordionController = ExpansibleController();
    final list = ListView.separated(
      shrinkWrap: displayAccordion,
      physics: displayAccordion ? NeverScrollableScrollPhysics() : null,
      itemCount: dataList.length,
      itemBuilder: ((context, index) {
        final item = dataList[index];
        final curve = item.curve?.icon;
        return ListTile(
          title: Text(item.value),
          subtitle: Text(item.createdAt.formattedDateTime()),
          trailing: curve != null ? Icon(curve) : null,
        );
        // TODO - use when delete weight record is available
        // return Dismissible(
        //   key: Key(weight.id!),
        //   behavior: .opaque,
        //   child: ListTile(
        //     title: Text("${weight.value} kg"),
        //     subtitle: Text(weight.createdAt.formattedDateTime()),
        //   ),
        // );
      }),
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 1,
          width: MediaQuery.sizeOf(context).width,
          child: Container(color: DsColors.gray),
        );
      },
    );
    if (displayAccordion) {
      return Expansible(
        headerBuilder: (context, _) {
          return Container(
            padding: EdgeInsets.all(DsSpacing.xxl),
            color: DsColors.gray,
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(accordionHeader!),
                Icon(
                  accordionController.isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ).touchEvents(onTap: () => accordionController.toggle());
        },
        bodyBuilder: (context, _) {
          return list;
        },
        controller: accordionController,
      );
    }

    return Flexible(child: list);
  }
}

enum MeasurementsListCurve {
  asc,
  desc,
  nochange;

  IconData? get icon {
    switch (this) {
      case .asc:
        return Icons.trending_up_sharp;
      case .desc:
        return Icons.trending_down_sharp;
      case .nochange:
        return null;
    }
  }
}

class MeasurementsListItem {
  final String id;
  final String value;
  final MeasurementsListCurve? curve;
  final DateTime createdAt;

  const MeasurementsListItem({
    required this.id,
    required this.value,
    required this.createdAt,
    this.curve,
  });
}
