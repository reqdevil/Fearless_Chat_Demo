// ignore_for_file: file_names
import 'dart:ui';
import 'package:fearless_chat_demo/Widgets/CustomButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String? title, descriptions, submitText, cancelText;
  final Image? img;
  final Widget widget;
  final Function? function;
   CustomDialogBox(
      {Key? key,
      this.title,
      this.descriptions,
      this.submitText,
      this.cancelText,
      this.img,
      required this.widget,
      this.function})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: [
        Container(
          padding:const EdgeInsets.only(left: 20, top: 15, right: 20, bottom: 15),
          // margin: EdgeInsets.only(top: avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 5), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: widget.widget,
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics:const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.title!.isNotEmpty,
                        child: Text(
                          widget.title!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            // fontFamily: 'Roboto',
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                     const SizedBox(
                        height: 15,
                      ),
                      Text(
                        widget.descriptions!,
                        style: TextStyle(
                          fontSize: 14,
                          // fontFamily: 'Roboto',
                          color: Colors.grey[800],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(
                height: 22,
              ),
              Visibility(
                visible: widget.cancelText != null,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CustomButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      buttonHeight: 30.0,
                     
                      labelText:
                          widget.cancelText != null ? widget.cancelText! : "",
                      isShadowed: true,
                      textColor: Colors.white),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: CustomButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      if (widget.function != null) {
                        widget.function!.call();
                      }
                    },
                    buttonHeight: 30.0,
                    
                    labelText: widget.submitText!,
                    isShadowed: true,
                    textColor: Colors.white),
              )
            ],
          ),
        ),

        // Positioned(
        //   left: padding,
        //   right: padding,
        //   child: CircleAvatar(
        //     backgroundColor: AppColors.white,
        //     radius: avatarRadius,
        //     child: ClipRRect(
        //         borderRadius: BorderRadius.all(Radius.circular(avatarRadius)),
        //         child: Icon(
        //           Icons.warning_outlined,
        //           color: AppColors.warningColor,
        //           size: 50.0,
        //         )),
        //   ),
        // ),
      ],
    );
  }
}
