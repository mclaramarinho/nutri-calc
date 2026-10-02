import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/core/utils/extensions/ext_widget.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_dismissible_tile/ds_dismissible_tile.dart';

class MeasurementsList extends StatelessWidget {
  final List<MeasurementsListItem> dataList;
  final bool displayAccordion;
  final String? accordionHeader;
  // ADR 0010: closes the pre-existing commented-out `Dismissible` TODO for
  // Weights/Heights/Body Measurements. `null` keeps this list read-only
  // (e.g. for call sites that don't yet want delete-on-swipe).
  final Future<Result<void, String>> Function(String id)? onDelete;

  const MeasurementsList({
    required this.dataList,
    this.displayAccordion = false,
    this.accordionHeader,
    this.onDelete,
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
        final tile = ListTile(
          title: Text(item.value),
          subtitle: Text(item.createdAt.formattedDateTime()),
          trailing: curve != null ? Icon(curve) : null,
        );

        if (onDelete == null) return tile;

        return DsDismissibleTile(
          itemKey: Key(item.id),
          confirmTitle: "Excluir",
          confirmMessage: "Deseja realmente excluir esta medida?",
          onDelete: () => onDelete!(item.id),
          child: tile,
        );
      }),
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 1,
          width: MediaQuery.sizeOf(context).width,
          child: Container(color: DsColors.of(context).gray),
        );
      },
    );
    if (displayAccordion) {
      return Expansible(
        headerBuilder: (context, _) {
          return Container(
            padding: EdgeInsets.all(DsSpacing.xxl),
            color: DsColors.of(context).gray,
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
