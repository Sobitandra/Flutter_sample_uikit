import 'package:flutter/material.dart';

import 'chat_friend_tab.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: TabBar(
          physics: const BouncingScrollPhysics(),
          isScrollable: true,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Group")
            // Tab(text: S.of(context).groups),)
          ],
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            AmitySLEChannelScreen(),
            // ChatGroupTabScreen(),
          ],
        ),
      ),
    );
  }
}
