import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class RegisterAddressPage extends StatefulWidget {
  const RegisterAddressPage({super.key});

  @override
  State<RegisterAddressPage> createState() => _RegisterAddressPageState();
}

class _RegisterAddressPageState extends State<RegisterAddressPage> {
  Country? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, c, __) => Scaffold(
        appBar: AppBar(title: const Text('Address Information')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      onSelect: (country) {
                        setState(() => selectedCountry = country);
                        c.country.text = country.name;
                      },
                    );
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      selectedCountry?.name ?? 'Select Country',
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                AuthTextField(
                  controller: c.region,
                  label: 'Region / Province',
                  icon: Icons.map,
                ),
                const SizedBox(height: 15),

                AuthTextField(
                  controller: c.city,
                  label: 'City',
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 15),

                AuthTextField(
                  controller: c.street,
                  label: 'Street Address',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 15),

                AuthTextField(
                  controller: c.postalCode,
                  label: 'Postal Code',
                  icon: Icons.post_add,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: c.loading
                        ? null
                        : () async {
                            final err = await c.submitRegistration();
                            if (err != null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(err)));
                              return;
                            }
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/dashboard');
                            }
                          },
                    child: c.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('FINISH REGISTRATION'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
