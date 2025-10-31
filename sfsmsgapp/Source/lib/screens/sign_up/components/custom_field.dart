import 'package:flutter/material.dart';

// Import Third Party Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CustomField extends StatefulWidget {
  final Map<String, dynamic> field;
  const CustomField(this.field, {super.key});

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  @override
  Widget build(BuildContext context) {
    final Widget customField;
    switch (widget.field['type']) {
      case 'textbox':
        customField = TextFormField(
          decoration: InputDecoration(
            labelText: widget.field['label'],
            hintText: widget.field['description'],
          ),
          validator: widget.field['validator'],
          onChanged: (value) {
            setState(() {
              widget.field['value'] = value;
            });
          },
        );
        break;
      case 'textarea':
        customField = TextFormField(
          maxLines: 5,
          decoration: InputDecoration(
            labelText: widget.field['label'],
            hintText: widget.field['description'],
          ),
          validator: widget.field['validator'],
          onChanged: (value) {
            setState(() {
              widget.field['value'] = value;
            });
          },
        );
        break;
      case 'selectbox':
        customField = DropdownButtonFormField(
          decoration: InputDecoration(
            hintText: widget.field['description'],
          ),
          items: widget.field['options'].asMap().entries.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option.key.toString(),
              child: Text(option.value.toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              widget.field['value'] = value;
            });
          },
          validator: widget.field['validator'],
        );
        break;
      case 'multipleselectbox':
        customField = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFB0B0B0),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
          child: MultiSelectDialogField(
            confirmText: Text(tr('Confirm')),
            cancelText: Text(tr('Cancel')),
            buttonIcon: const Icon(Icons.arrow_drop_down),
            items: widget.field['options'].asMap().entries.map<MultiSelectItem<String>>((option) {
              return MultiSelectItem<String>(option.key.toString(), option.value.toString());
            }).toList(),
            initialValue: widget.field['value'],
            title: Text(widget.field['label']),
            buttonText: Text(widget.field['label']),
            onConfirm: (values) {
              setState(() {
                widget.field['value'] = values;
              });
            },
            validator: widget.field['validator'],
          ),
        );
        break;
      default:
        return const SizedBox(height: 0);
    }
    return Column(
      children: [
        customField,
        const SizedBox(height: 25),
      ],
    );
  }
}
