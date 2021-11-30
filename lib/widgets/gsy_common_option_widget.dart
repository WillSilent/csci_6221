import 'package:flutter/material.dart';
import 'package:fluttergithub/l10n/localization_intl.dart';
import 'package:fluttergithub/common/util/CommonUtil.dart' as commonUtil;

class GSYCommonOptionWidget extends StatelessWidget {
  final List<GSYOptionModel> otherList;

  final String url;

  GSYCommonOptionWidget({this.otherList, String url})
      : this.url = (url == null) ? "https://www.github.com/login" : url;

  _renderHeaderPopItem(List<GSYOptionModel> list) {
    return new PopupMenuButton<GSYOptionModel>(
      child: new Icon(Icons.more),
      onSelected: (model) {
        model.selected(model);
      },
      itemBuilder: (BuildContext context) {
        return _renderHeaderPopItemChild(list);
      },
    );
  }

  _renderHeaderPopItemChild(List<GSYOptionModel> data) {
    List<PopupMenuEntry<GSYOptionModel>> list = [];
    for (GSYOptionModel item in data) {
      list.add(PopupMenuItem<GSYOptionModel>(
        value: item,
        child: new Text(item.name),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    List<GSYOptionModel> constList = [
      GSYOptionModel(GmLocalizations.of(context).option_web,
          GmLocalizations.of(context).option_web, (model) {
        commonUtil.launchOutURL(url, context);
      }),
      GSYOptionModel(GmLocalizations.of(context).option_copy,
          GmLocalizations.of(context).option_copy, (model) {
            commonUtil.copy(url ?? "", context);
      }),
    ];
    var list = [...constList, ...?otherList];
    return _renderHeaderPopItem(list);
  }
}

class GSYOptionModel {
  final String name;
  final String value;
  final PopupMenuItemSelected<GSYOptionModel> selected;

  GSYOptionModel(this.name, this.value, this.selected);
}
