import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/services.dart';

class MapService {


  static Map<String, dynamic> sortMap(String sortType, Map<String, dynamic> info, dynamic Function(Map<String,dynamic>)selector){

    String setting=SettingsService.getSetting(sortType);
    Map<String,dynamic> sorted={};
    if(setting.toLowerCase()=="alphabetical"){
        final entries=info.entries.toList();

        entries.sort(
          (a,b){
            return selector(a.value).compareTo(selector(b.value));
          }
        );

        sorted= Map.fromEntries(entries);        
    }
    return sorted;
  }
}