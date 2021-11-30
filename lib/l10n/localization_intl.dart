import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart'; //1

class GmLocalizations {
  String get loading_text => Intl.message('loading_text', name: 'loading_text');

  String get option_web => Intl.message('option_web', name: 'option_web');

  String get option_copy => Intl.message('option_copy', name: 'option_copy');

  get option_share_copy_success => Intl.message('option_share_copy_success', name: 'option_share_copy_success');

  get option_web_launcher_error => Intl.message('option_web_launcher_error', name: 'option_web_launcher_error');

  get fansi => Intl.message('fansi', name: 'fansi');

  static Future<GmLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    //2
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new GmLocalizations();
    });
  }

  static GmLocalizations of(BuildContext context) {
    return Localizations.of<GmLocalizations>(context, GmLocalizations);
  }

  String get title {
    return Intl.message(
      'Flutter APP',
      name: 'title',
      desc: 'Title for the Demo application',
    );
  }

  String get home => Intl.message('Github', name: 'home');

  String get language => Intl.message('Language', name: 'language');

  String get login => Intl.message('Login', name: 'login');

  String get auto => Intl.message('Auto', name: 'auto');

  String get setting => Intl.message('Setting', name: 'setting');

  String get theme => Intl.message('Theme', name: 'theme');

  String get noDescription =>
      Intl.message('No description yet !', name: 'noDescription');

  String get userName => Intl.message('User Name', name: 'userName');
  String get userNameRequired => Intl.message("User name required!" , name: 'userNameRequired');
  String get password => Intl.message('Password', name: 'password');
  String get passwordRequired => Intl.message('Password required!', name: 'passwordRequired');
  String get userNameOrPasswordWrong=>Intl.message('User name or password is not correct!', name: 'userNameOrPasswordWrong');
  String get logout => Intl.message('Logout', name: 'logout');
  String get logoutTip => Intl.message('Are you sure you want to quit your current account?', name: 'logoutTip');
  String get yes => Intl.message('yes', name: 'yes');
  String get cancel => Intl.message('cancel', name: 'cancel');
  String get test => Intl.message('test', name: 'test');
  String get trend => Intl.message('trend', name: 'trend');
  String get repos => Intl.message('repos', name: 'repos');
  String get developers => Intl.message('developers', name: 'developers');
  String get info => Intl.message('info', name: 'info');
  String get file => Intl.message('file', name: 'file');
  String get commit => Intl.message('commit', name: 'commit');
  String get activity => Intl.message('activity', name: 'activity');
  String get size => Intl.message('size', name: 'size');
  String get myStarRepos => Intl.message('My Star',name: 'myStarRepos');
  String get myFollow => Intl.message('My Follow',name: 'myFollow');
  String get thisProject =>Intl.message('This Project',name: 'thisProject');
  String get repositories => Intl.message('repositories',name: 'repositories');
  String get footprint => Intl.message('footprint',name: 'footprint');
  String get me=>Intl.message('me',name: 'me');

}

//Locale代理类
class GmLocalizationsDelegate extends LocalizationsDelegate<GmLocalizations> {
  const GmLocalizationsDelegate();

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<GmLocalizations> load(Locale locale) {
    //3
    return GmLocalizations.load(locale);
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(GmLocalizationsDelegate old) => false;
}
