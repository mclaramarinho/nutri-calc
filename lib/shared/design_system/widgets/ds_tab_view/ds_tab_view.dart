import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/utils/extensions/ext_num_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_tab_view/ds_tab_bar_delegate.dart';

class DsTabView extends StatefulWidget {
  final List<Widget> tabsContents;
  final List<Widget> tabs;
  final Widget? header;
  final Widget? persistentHeader;

  const DsTabView({
    required this.tabs,
    required this.tabsContents,
    this.header,
    this.persistentHeader,
    super.key,
  }) : assert(tabs.length >= 1, "Tabs length must be >= 1"),
       assert(tabsContents.length >= 1, "Tabs Contents length must be >= 1");

  @override
  State<StatefulWidget> createState() => _DsTabView();
}

class _DsTabView extends State<DsTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: 1,
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            if (widget.header != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: widget.header,
                ),
              ),
            ],

            if (widget.persistentHeader != null) ...[widget.persistentHeader!],

            SliverPersistentHeader(
              pinned: true,
              delegate: TabBarDelegate(
                TabBar(controller: _tabController, tabs: widget.tabs),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: widget.tabsContents,
        ),
      ),
    );
  }
}
