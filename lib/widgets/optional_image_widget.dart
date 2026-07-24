import 'package:flutter/material.dart';

import 'package:dnd_app/services/icon_service.dart';

class OptionalImageWidget extends StatefulWidget {
  final String path;
  final double height;
  
  OptionalImageWidget(
    this.height,
    this.path,
    {super.key}
    );

  @override
  State<OptionalImageWidget>  createState()=>_OptionalImageWidgetState();

} 

class _OptionalImageWidgetState extends State<OptionalImageWidget>{
  
  Image? image;

  @override
  void initState(){
    super.initState();
    image=IconService.getIcon(widget.path);
  }


  @override
  Widget build(BuildContext context){

    return SizedBox(
      height: widget.height,
      width: widget.height,
      child: ClipOval(
        child: image
      ),
    );
  }
}