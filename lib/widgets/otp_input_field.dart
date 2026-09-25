import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';

class OtpInputRow extends StatefulWidget {
  final int length;
  final ValueChanged<String> onOtpChanged;

  const OtpInputRow({
    super.key,
    this.length = 6,
    required this.onOtpChanged,
  });

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _currentOtp = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (value.length > widget.length) {
      value = value.substring(0, widget.length);
      _controller.text = value;
      _controller.selection = TextSelection.collapsed(offset: value.length);
    }
    setState(() {
      _currentOtp = value;
    });
    widget.onOtpChanged(value);

    // Auto unfocus when OTP is completely filled
    if (value.length == widget.length) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;
    final int currentLength = _currentOtp.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Hidden real TextField handling single iOS/Android keyboard session
        Opacity(
          opacity: 0.0,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            onChanged: _onTextChanged,
            enableSuggestions: false,
            autocorrect: false,
            showCursor: false,
          ),
        ),

        // Visual 6-Box OTP Display Row
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final bool hasValue = index < currentLength;
              final String digit = hasValue ? _currentOtp[index] : '';
              final bool isBoxActive = isFocused &&
                  (index == currentLength || (index == widget.length - 1 && currentLength == widget.length));

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBoxActive
                        ? AppColors.primary
                        : (hasValue ? AppColors.primary.withValues(alpha: 0.4) : AppColors.inputBorder),
                    width: isBoxActive ? 2.0 : 1.5,
                  ),
                  boxShadow: isBoxActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
