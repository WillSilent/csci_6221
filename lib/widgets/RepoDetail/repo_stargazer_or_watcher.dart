import 'package:flukit/flukit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttergithub/common/net/NetApi.dart';
import 'package:fluttergithub/models/index.dart';
import 'package:fluttergithub/widgets/PersonItem.dart';
import 'package:fluttergithub/widgets/myWidgets/no_data_or_no_net.dart';

class RepoStarOrWatcherList extends StatefulWidget {
  RepoStarOrWatcherList(this.repoOwner, this.repoName,
      {@required this.isStargazer});

  final String repoOwner;
  final String repoName;
  final bool isStargazer;

  @override
  State<StatefulWidget> createState() {
    return _RepoStarOrWatcherState();
  }
}

class _RepoStarOrWatcherState extends State<RepoStarOrWatcherList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext mContext) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.isStargazer ? 'Stargazers' : 'Watchers',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                widget.repoOwner + '/' + widget.repoName,
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ],
          ),
        ),
      ),
      body: InfiniteListView<UserBean>(
        emptyBuilder: (VoidCallback refresh, BuildContext context){
          return listNoDataView(refresh, context);
        },
        onRetrieveData: (int page, List<UserBean> items, bool refresh) async {
          var data = await NetApi(context).getRepoStargazersOrWatcher(
            repoOwner: widget.repoOwner,
            repoName: widget.repoName,
            isStargazers: widget.isStargazer,
            queryParameters: {
              'page': page,
              'page_size': 30,
            },
          );
          //?????????????????????????????????items???
          items.addAll(data);
          // ?????????????????????????????????'page_size'??????????????????????????????????????????????????????
          return data.length == 30;
        },
        itemBuilder: (List list, int index, BuildContext ctx) {
          // ?????????????????????
          return PersonItem(
            personData: list[index],
          );
        },
      ),
    );
  }
}
