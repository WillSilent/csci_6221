import 'dart:convert';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttergithub/common/constant/constant.dart';
import 'package:fluttergithub/models/index.dart';
import '../Global.dart';
import '../constant/ignore.dart';
import 'api.dart';

class NetApi {
  // 在网络请求过程中可能会需要使用当前的context信息，比如在请求失败时
  // 打开一个新路由，而打开新路由需要context信息。
  NetApi([this.context]) {
    _options = Options(extra: {"context": context});
  }

  BuildContext context;
  Options _options;

  //github OAuth认证需要，没有认证某些接口访问次数限制为60次/小时，认证后为5000次/小时
  final Map oAuthParams = {
    "scopes": ['user', 'repo'],
    "note": "admin_script",
    "client_id": Ignore.clientId,
    "client_secret": Ignore.clientSecret
  };
  static Dio dio = new Dio();

  static void init() {
    //添加缓存插件
    // dio.interceptors.add(Global.netCache);
    //设置用户token(可能为null，代表未登录)
    // dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
    //在调试模式下需要抓包调试，所以我们使用代理，并禁用HTTPS证书校验
//    if (!Global.isRelease) {
//      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//          (client) {
//        client.findProxy = (uri) {
//          return "PROXY 10.95.249.53:8888";
//        };
//        //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
//        client.badCertificateCallback =
//            (X509Certificate cert, String host, int port) => true;
//      };
//    }
  }

  getAuthorization() {
    String basic = Global.prefs.get(Constant.BASIC_KEY);
    print(basic);
    return basic;
  }

  //GitHub API OAuth认证，获取token
  void passOAuth(String basic) async {
    var urlOauth = Api.getAuthorizations();
    _options.method = "post";
    _options.headers["Authorization"] = basic;
    var r = await dio.request(urlOauth,
        data: json.encode(oAuthParams), options: _options);

    print(r.data['token']);
    if (r.data['token'] != null) {
      //更新profile中的token信息
      Global.profile.token = r.data['token'];
    }
  }

  Future<UserBean> authLogin(String code) async{
    //obtain the accesstoken
    var tokenUrl = "https://github.com/login/oauth/access_token?client_id=c66630468b192d2d95d3&client_secret=1017e95bda2cb18ff9a9425c66021df2a4769bc6&code=" + code;
    _options.method = "get";
    _options.headers["accept"] = "application/json";
    var r = await dio.request(tokenUrl, options: _options);
    TokenModel token = TokenModel.fromJson(r.data);

    if (r.data['token'] != null) {
      //更新profile中的token信息
      Global.profile.token = token.accessToken;
    }

    //login
    var loginUrl = 'https://api.github.com/user';
    _options.method = "get";
    _options.headers["Authorization"] = 'token ' + token.accessToken;
    var response = await dio.request(loginUrl, options: _options);
    UserBean user = UserBean.fromJson(response.data);

    //设置全局值
    Global.profile.user = user;
    Global.profile.token = token.accessToken;
    Global.prefs.setString(Constant.USER_NAME_KEY, user.login);
    Global.prefs.setString(Constant.BASIC_KEY, 'token ' + token.accessToken);
    return user;
  }


  // 登录接口，登录成功后返回用户信息
  Future<UserBean> login(String username, String pwd) async {
    String basic = 'Basic ' + base64.encode(utf8.encode('$username:$pwd'));
    //存储用户名、密码、basic到sp
    Global.prefs.setString(Constant.USER_LOGIN_KEY, username);
    Global.prefs.setString(Constant.PASSWORD_KEY, pwd);
    Global.prefs.setString(Constant.BASIC_KEY, basic);

    passOAuth(basic);
    //登录成功后更新公共头（authorization），此后的所有请求都会带上用户身份信息
    //dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    //清空所有缓存
    //Global.netCache.cache.clear();
    //更新profile中的token信息
    //Global.profile.token = basic;

    var urlLogin = Api.getUser(username);
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    //Basic TXJIR0o6SGdqOTQwNjI3
    var response = await dio.request(urlLogin, options: _options);
    UserBean data = UserBean.fromJson(response.data);
    Global.prefs.setString(Constant.USER_NAME_KEY, data.login);
    return data;
  }

  //获取用户项目列表
  Future<List<RepoBean>> getRepos(
      {String repoOwner,
      Map<String, dynamic> queryParameters, //query参数，用于接收分页信息
      refresh = false}) async {
    if (refresh) {
      // 列表下拉刷新，需要删除缓存（拦截器中会读取这些信息）
      //_options.extra.addAll({"refresh": true, "list": true});
    }
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getRepos(repoOwner);
    var r = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return r.data.map((e) => RepoBean.fromJson(e)).toList();
  }

  //获取项目repo详情信息
  Future<RepoDetailBean> getRepoDetail(
      String repoOwner, String repoName) async {
    var url = Api.getRepoDetail(repoOwner, repoName);
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var response = await dio.request(url, options: _options);
    return RepoDetailBean.fromJson(response.data);
  }

  //获取star或者watch仓库人的列表
  Future<List<UserBean>> getRepoStargazersOrWatcher(
      {@required repoOwner,
      @required repoName,
      @required isStargazers,
      Map<String, dynamic> queryParameters}) async {
    var url;
    if (isStargazers) {
      url = Api.getRepoStargazers(repoOwner, repoName);
    } else {
      url = Api.getRepoWatchers(repoOwner, repoName);
    }
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var response = await dio.request<List>(url,
        queryParameters: queryParameters, options: _options);
    return response.data.map((e) => UserBean.fromJson(e)).toList();
  }

  //获取项目repo分支
  Future<List<BranchBean>> getRepoBranch(
      String repoOwner, String repoName) async {
    var url = Api.getBranch(repoOwner, repoName);
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var response = await dio.request<List>(url, options: _options);
    return response.data.map((e) => BranchBean.fromJson(e)).toList();
  }

  //获取readme
  Future<ReadmeBean> getReadme({repoOwner, repoName, branch = 'master'}) async {
    var url = Api.getReadme(repoOwner, repoName);
    if (branch != 'master') {
      url += '?ref=' + branch;
    }
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var response = await dio.request(url, options: _options);
    return ReadmeBean.fromJson(response.data);
  }

  //获取repo的commits列表
  Future<List<CommitItemBean>> getCommits(String repoOwner, String repoName,
      {Map<String, dynamic> queryParameters, //query参数，用于接收分页信息
      branch = 'master'}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getRepoCommits(repoOwner, repoName);
    if (branch != 'master') {
      url += '?sha=' + branch;
    }
    var r = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return r.data.map((e) => CommitItemBean.fromJson(e)).toList();
  }

  //获取repo的commits详情
  Future<CommitDetailBean> getCommitsDetail(
      String repoOwner, String repoName, String sha,
      {branch = 'master'}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getRepoCommitsDetail(repoOwner, repoName, sha);
    if (branch != 'master') {
      url += '?sha=' + branch;
    }
    var r = await dio.request(
      url,
      options: _options,
    );
    return CommitDetailBean.fromJson(r.data);
  }

  //获取repo的activity列表
  Future<List<EventBean>> getEvents(String repoOwner, String repoName,
      {Map<String, dynamic> queryParameters, //query参数，用于接收分页信息
      refresh = false}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getRepoEvents(repoOwner, repoName);
    var r = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return r.data.map((e) => EventBean.fromJson(e)).toList();
  }

  //获取repo内容
  Future<List<FileBean>> getReposContent(
      String repoOwner, String repoName, String path,
      {Map<String, dynamic> queryParameters, //query参数，用于接收分页信息
      branch = 'master'}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getRepoContent(repoOwner, repoName, path);
    if (branch != 'master') {
      url += '?ref=' + branch;
    }
    var r = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return r.data.map((e) => FileBean.fromJson(e)).toList();
  }

  //获取repo中代码内容
  Future<String> getReposCodeFileContent(
      String repoOwner, String repoName, String path,
      {branch = 'master'}) async {
    _options.method = "get";
    _options.headers["Accept"] = 'application/vnd.github.html';
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getRepoContent(repoOwner, repoName, path);
    if (branch != 'master') {
      url += '?ref=' + branch;
    }
    var r = await dio.request(
      url,
      options: _options,
    );
    return r.data;
  }

  // 获取个人信息
  Future<UserBean> getUserInfo(String username) async {
    var url = Api.getUser(username);
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var response = await dio.request(url, options: _options);
    return UserBean.fromJson(response.data);
  }

  //获取用户starred项目列表
  Future<List<RepoBean>> getStarredRepoList(
      {String userName, Map<String, dynamic> queryParameters}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getStarredRepos(userName);
    var response = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data.map((e) => RepoBean.fromJson(e)).toList();
  }

  //获取repo的activity列表
  Future<List<EventBean>> getUserEvents(
      {String userName, Map<String, dynamic> queryParameters}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.getUserEvents(userName);
    var response = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data.map((e) => EventBean.fromJson(e)).toList();
  }

  //获取用户的following或follower
  Future<List<UserBean>> getFollowList(
      {@required String userName,
      @required bool isGetFollowing,
      Map<String, dynamic> queryParameters}) async {
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url;
    if (isGetFollowing) {
      url = Api.getUserFollowing(userName);
    } else {
      url = Api.getUserFollower(userName);
    }
    var response = await dio.request<List>(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data.map((e) => UserBean.fromJson(e)).toList();
  }

  //搜索仓库
  Future<List<RepoBean>> searchRepos(
      {@required String keyWords,
      String sort = 'best match',
      String order = 'desc',
      Map<String, dynamic> queryParameters}) async {
    String type = 'repositories';
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.search(type, keyWords, sort, order);
    var response = await dio.request(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data['items']
        .map<RepoBean>((e) => RepoBean.fromJson(e))
        .toList();
  }

  //搜索仓库
  Future<List<UserBean>> searchUsers(
      {@required String keyWords,
      String sort = 'best match',
      String order = 'desc',
      Map<String, dynamic> queryParameters}) async {
    String type = 'users';
    _options.method = "get";
    _options.headers["Authorization"] = await getAuthorization();
    var url = Api.search(type, keyWords, sort, order);
    var response = await dio.request(
      url,
      queryParameters: queryParameters,
      options: _options,
    );
    return response.data['items']
        .map<UserBean>((e) => UserBean.fromJson(e))
        .toList();
  }

  //获取trending repos 项目排行榜
  Future<List<TrendRepoBean>> getTrendingRepos(
      String since, String language) async {
    var url = Api.getTrendingRepos(since, language);
    var response = await dio.get<List>(url);
    return response.data.map((item) => TrendRepoBean.fromJson(item)).toList();
  }

  //获取trending developers developer排行榜
  Future<List<TrendDeveloperBean>> getTrendingDevelopers(
      String since, String language) async {
    var url = Api.getTrendDevelopers(since, language);
    var response = await dio.get<List>(url);
    return response.data
        .map((item) => TrendDeveloperBean.fromJson(item))
        .toList();
  }

  //检查是否star
  Future<int> checkIsStar({String repoOwner, String repoName}) async {
    var url = Api.isStarred(repoOwner, repoName);
    var responses;
    _options.method = "get";
    _options.headers["Authorization"] = getAuthorization();
    try {
      responses = await dio.request(url, options: _options);
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
//        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        //print(e.type);
      }
      return 404;
    }
    return responses.statusCode;
  }

  //对项目进行star或者unstar
  Future<int> starOrUnStar(
      {String repoOwner, String repoName, bool isStarred}) async {
    var url = Api.isStarred(repoOwner, repoName);
    var responses;
    _options.method = !isStarred ? 'PUT' : 'DELETE';
    _options.headers["Authorization"] = getAuthorization();
    try {
      responses = await dio.request(url, options: _options);
    } on DioError catch (e) {
      return 404;
    }
    return responses.statusCode;
  }

  //检查是否following
  Future<int> checkIsFollowing({String developerName}) async {
    var url = Api.isFollowing(developerName);
    var responses;
    _options.method = "get";
    _options.headers["Authorization"] = getAuthorization();
    try {
      responses = await dio.request(url, options: _options);
    } on DioError catch (e) {
      if (e.response != null) {
        print(e.response.data);
        print(e.response.headers);
//        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        //print(e.type);
      }
      return 404;
    }
    return responses.statusCode;
  }

  //对developer进行Follow或者UnFollow
  Future<int> followOrUnFollow({String developerName, bool isFollowed}) async {
    var url = Api.isFollowing(developerName);
    var responses;
    _options.method = !isFollowed ? 'PUT' : 'DELETE';
    _options.headers["Authorization"] = getAuthorization();
    try {
      responses = await dio.request(url, options: _options);
    } on DioError catch (e) {
      return 404;
    }
    return responses.statusCode;
  }
}


class TokenModel {
  String accessToken;
  String scope;
  String tokenType;

  TokenModel({this.accessToken, this.scope, this.tokenType});

  TokenModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    scope = json['scope'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['scope'] = this.scope;
    data['token_type'] = this.tokenType;
    return data;
  }
}
