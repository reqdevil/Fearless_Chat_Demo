import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final GestureTapCallback? onPressed;
  final String? labelText;
  final String? secondaryLabelText;
  final Icon? icon;
  final double? buttonHeight;
  final double? buttonWidth;
  // final ContentFontWeigth? fontWeigth;
  final bool? isEnabled;
  final Color? textColor;
  final bool? isShadowed;
  // final ButtonType? buttonType;
  final TextAlign? textAlign;
  final double? letterSpacing;

 const CustomButton({
    Key? key,
    required this.onPressed,
    this.labelText,
    this.icon,
    this.buttonHeight,
    this.buttonWidth,
    // this.fontWeigth = ContentFontWeigth.regular,
    this.secondaryLabelText = "",
    this.textColor,
    this.isShadowed = false,
    // this.buttonType = ButtonType.submitGrey,
    this.textAlign = TextAlign.center,
    this.letterSpacing,
    this.isEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      height: buttonHeight,
      width: buttonWidth,
      decoration: isShadowed!
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.5),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(-1, 9),
                ),
              ],
            )
          : null,
      child: RawMaterialButton(
        fillColor: Colors.grey,
        child: Padding(
          padding: EdgeInsets.zero,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 8,
                      child: RichText(
                        maxLines: 1,
                        textAlign: textAlign!,
                        text: TextSpan(
                          text: labelText,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            letterSpacing: letterSpacing,
                          ),
                          children: secondaryLabelText != ""
                              ? <TextSpan>[
                                  TextSpan(
                                    text: secondaryLabelText,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      letterSpacing: letterSpacing,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ]
                              : <TextSpan>[],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: icon,
                      ),
                    )
                  ],
                )
              : RichText(
                  maxLines: 1,
                  textAlign: textAlign!,
                  text: TextSpan(
                    text: labelText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      letterSpacing: 0.2,
                    ),
                    children: secondaryLabelText != ""
                        ? <TextSpan>[
                            TextSpan(
                              text: secondaryLabelText,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                letterSpacing: 2.29,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ]
                        : <TextSpan>[],
                  ),
                ),
        ),
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
