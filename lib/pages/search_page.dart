import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onex/manager/api_manager.dart';
import 'package:flutter_onex/model/SearchBean.dart';
import 'package:flutter_onex/pages/webview_page.dart';
import 'package:flutter_onex/widget/ClearableInputField.dart';
import 'package:flutter_onex/widget/ProgressView.dart';

/*
*  搜索页
*/
class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Search();
  }
}

class Search extends State<SearchPage> {
  var _key = '';
  List<Article> articles = List();

  int _index = 0;

  var _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: creteBody(context),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _loadmore.dispose();
    super.dispose();
  }

  AppBar _buildAppbar(BuildContext context) {
    var originTheme = Theme.of(context);
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.maybePop(context);
          }),
      title: Theme(
          data: originTheme.copyWith(
            hintColor: Colors.white,
            textTheme: TextTheme(subhead: TextStyle(color: Colors.white)),
          ),
          child: ClearableInputField(
            hintTxt: '搜索的内容',
            controller: _controller,
            border: InputBorder.none,
            onchange: (str) {
              setState(() {
                _key = str;
                _getSearchArticle(_index, _key);
              });
            },
          )),
    );
  }



  ScrollController _loadmore = new ScrollController();

  @override
  bool get wantKeepAlive => true;

  Widget creteBody(BuildContext context) {
    Widget listView = ListView.builder(
        controller: _loadmore,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return createHomeArticleItem(articles[index]);
        });

    return new Scaffold(
        body: Stack(children: <Widget>[
        articles.length == 0 ? new Text("没有数据") : listView,
    ]));
  }

  @override
  void initState() {
    super.initState();

    _loadmore.addListener(() {
      var position = _loadmore.position;
      // 小于50px时，触发上拉加载；
      if (position.maxScrollExtent - position.pixels < 50) {
        this._index++;
        this._getSearchArticle(_index, _key);
      }
    });
  }

  void _getSearchArticle(int index, String key) async {
    Response response = await ApiManager().searchArticle(index, key);
    if(null!=response) {
      var articleBean = SearchBean.fromJson(response.data);
      setState(() {
        articles.addAll(articleBean.data.datas);
      });
    }else{
      articles.clear();
    }
  }

  Widget createHomeArticleItem(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (ctx) =>
                    WebViewPage(title: article.title, url: article.link)));
      },
      child: Card(
          margin: EdgeInsets.fromLTRB(2, 5, 2, 0),
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.child_care,
                      color: Colors.blueAccent,
                      size: 18,
                    ),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            article.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ))
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      article.title
                          .replaceAll("&rdquo;", "")
                          .replaceAll("&ldquo;", ""),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                      size: 15,
                    ),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            article.niceDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ))
                  ],
                )
              ],
            ),
          )),
    );
  }
}
