import 'package:electricity_plus/helper/loading/loading_screen.dart';
import 'package:electricity_plus/services/models/cloud_customer.dart';
import 'package:electricity_plus/utilities/helper_functions.dart';
import 'package:electricity_plus/views/operations/customer_search/bloc/customer_search_bloc.dart';
import 'package:electricity_plus/views/operations/management/edit_customer/bloc/edit_customer_bloc.dart';
import 'package:electricity_plus/views/operations/management/edit_customer/edit_customer_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCustomerView extends StatefulWidget {
  final CloudCustomer customer;
  const EditCustomerView({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  late final TextEditingController _nameController;
  late final TextEditingController _meterMultiplierController;
  late final TextEditingController _horsePowerUnitsController;
  late bool _checked;
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.customer.name);
    _meterMultiplierController = TextEditingController(
        text: widget.customer.meterMultiplier.toStringAsFixed(0));
    _horsePowerUnitsController = TextEditingController(
        text: widget.customer.horsePowerUnits.toStringAsFixed(0));
    _checked = false;
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _meterMultiplierController.dispose();
    _horsePowerUnitsController.dispose();
    _formKey.currentState!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditCustomerBloc, EditCustomerState>(
      listener: (context, state) async {
        if (state is EditCustomerStateLoading) {
          LoadingScreen().show(context: context, text: 'Loading...');
        } else {
          LoadingScreen().hide();
          if (state is EditCustomerStateSubmitted) {
            await showEditCustomerSuccessDialog(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Customer'),
          leading: BackButton(
            onPressed: () {
              context
                  .read<CustomerSearchBloc>()
                  .add(const CustomerSearchEditCustomerSearchInitialise());
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.customer.bookId,
                      decoration: const InputDecoration(
                        labelText: 'Book ID',
                      ),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'Enter customer name',
                      enabled: true,
                      autovalidateMode: AutovalidateMode.always,
                    ),
                    TextFormField(
                      initialValue: widget.customer.address,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _meterMultiplierController,
                      decoration:
                          const InputDecoration(labelText: 'Meter Multiplier'),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        return (value != null &&
                                (value.contains('.') ||
                                    value.contains('-') ||
                                    !isIntInput(value)))
                            ? 'Enter a valid unit'
                            : null;
                      },
                      enabled: true,
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _horsePowerUnitsController,
                      decoration:
                          const InputDecoration(labelText: 'HorsePower Units'),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        return (value != null &&
                                (value.contains('.') ||
                                    value.contains('-') ||
                                    !isIntInput(value)))
                            ? 'Enter a valid unit'
                            : null;
                      },
                      enabled: true,
                      keyboardType: TextInputType.number,
                    ),
                    CheckboxListTile(
                      value: _checked,
                      title: const Text('Has Road Light Cost'),
                      onChanged: (value) {
                        setState(() {
                          _checked = value ?? false;
                        });
                      },
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<EditCustomerBloc>().add(
                          EditCustomerEventSubmit(
                            hasRoadLightCost: _checked,
                            horsePowerUnits:
                                _horsePowerUnitsController.text.trim(),
                            meterMultiplier:
                                _meterMultiplierController.text.trim(),
                            name: _nameController.text.trim(),
                          ),
                        );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
