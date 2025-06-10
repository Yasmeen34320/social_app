import 'package:flutter/material.dart';

class CustomInputLabelForm extends StatefulWidget {
  final String label;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextEditingController controller;
  final bool isPassword;
  final int? maxlines;
  const CustomInputLabelForm({
    super.key,
    required this.hintText,
    required this.label,
    required this.validator,
    required this.controller,
    required this.isPassword,
    this.maxlines,
  });

  @override
  State<CustomInputLabelForm> createState() => _CustomInputLabelFormState();
}

class _CustomInputLabelFormState extends State<CustomInputLabelForm> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != '')
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 19,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (widget.label != '') const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          validator: widget.validator,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 17),
            // Remove errorStyle here to use default error placement
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 77, 10, 88),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 77, 10, 88),
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 186, 40, 29),
              letterSpacing: 2,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          maxLines: widget.maxlines != null ? widget.maxlines : 1,
        ),
      ],
    );
  }
}
