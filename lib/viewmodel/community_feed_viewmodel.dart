import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

import '../../components/alert_dialog.dart';

class CommuFeedVM extends ChangeNotifier {
  bool isCurrentUserIsAdmin = false;
  var _amityCommunityFeedPosts = <AmityPost>[];

  late PagingController<AmityPost> _controllerCommu;

  final scrollcontroller = ScrollController();

  List<AmityPost> getCommunityPosts() {
    return _amityCommunityFeedPosts;
  }

  void addPostToFeed(AmityPost post) {
    _controllerCommu.addAtIndex(0, post);
    notifyListeners();
  }

  Future<void> initAmityCommunityFeed(String communityId) async {
    isCurrentUserIsAdmin = false;

    //inititate the PagingController
    _controllerCommu = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getCommunityFeed(communityId)
          //feedType could be AmityFeedType.PUBLISHED, AmityFeedType.REVIEWING, AmityFeedType.DECLINED
          .feedType(AmityFeedType.PUBLISHED)
          .getPagingData(token: token, limit: 20),
      pageSize: 20,
    )..addListener(
        () async {
          log("communityListener");
          if (_controllerCommu.error == null) {
            //handle results, we suggest to clear the previous items
            //and add with the latest _controller.loadedItems
            _amityCommunityFeedPosts.clear();
            _amityCommunityFeedPosts.addAll(_controllerCommu.loadedItems);

            //update widgets
            notifyListeners();
          } else {
            //error on pagination controller
            await AmityDialog().showAlertErrorDialog(
                title: "Error!", message: _controllerCommu.error.toString());
            //update widgets

          }
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controllerCommu.fetchNextPage();
    });

    scrollcontroller.addListener(loadnextpage);

    //inititate the PagingController
    await AmitySocialClient.newFeedRepository()
        .getCommunityFeed(communityId)
        .getPagingData()
        .then((value) {
      _amityCommunityFeedPosts = value.data;
    });
    notifyListeners();
    await checkIsCurrentUserIsAdmin(communityId);
  }

  void loadnextpage() {
    if ((scrollcontroller.position.pixels ==
            scrollcontroller.position.maxScrollExtent) &&
        _controllerCommu.hasMoreItems) {
      _controllerCommu.fetchNextPage();
    }
  }

  void loadCoomunityMember() {}

  Future<void> checkIsCurrentUserIsAdmin(String communityId) async {
    print("LOG1 :checkIsCurrentUserIsAdmin");
    await AmitySocialClient.newCommunityRepository()
        .getCurentUserRoles(communityId)
        .then((value) {
      print("LOG1" + value.toString());
      for (var role in value) {
        if (role == "community-moderator") {
          isCurrentUserIsAdmin = true;
        }
      }
      notifyListeners();
    }).onError((error, stackTrace) {
      print("LOG1:$error");
    });
  }
}
