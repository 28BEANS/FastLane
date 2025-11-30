import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class CountryPickerField extends StatefulWidget {
  final String label;

  const CountryPickerField({
    super.key,
    required this.label,
  });

  @override 
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  Country selectedCountry = Country(
    phoneCode: '1',
    countryCode: 'US',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'United States',
    example: '123456789',
    displayName: 'United States (US)',
    displayNameNoCountryCode: 'United States',
    e164Key: '',
  );

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false, 
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget countryDisplay = Row(
        children: [
          Text(
            selectedCountry.flagEmoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              selectedCountry.name,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

      return GestureDetector(
        onTap: _openCountryPicker,
        child: SizedBox(
          width: 350,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              // The icon that indicates it's clickable
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: countryDisplay,
          ),
        ),
      );
    }
}