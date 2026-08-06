import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/services.dart';

class MapService {

  static Map<String, dynamic> sortMap(String sortType, Map<String, dynamic> info, [String key=""]){
    String setting=SettingsService.getSetting(sortType);
    Map<String,dynamic> sorted={};
    if(setting.toLowerCase()=="alphabetical"){
      if(key==""){
        final keys = info.keys.toList()..sort();
        for (final k in keys){
          sorted[k]=info[k];
        }
      }else{
        Map<String,dynamic> tmp={};
        final keys = info.keys.toList();
        for (final k in keys){
          tmp[info[k][key]]=k;
        }
        final sortedKeys=tmp.keys.toList()..sort();
        for (final k in sortedKeys){
          sorted[tmp[k]]=info[tmp[k]];
        }
      }
    }
    return sorted;
  }
}