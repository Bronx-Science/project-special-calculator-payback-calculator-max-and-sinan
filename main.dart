import 'package:flutter/material.dart';

void main() {
  runApp(SharedBillCalculatorApp());
}

class SharedBillCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SharedBillCalculatorScreen(),
    );
  }
}

class SharedBillCalculatorScreen extends StatefulWidget {
  @override
  _SharedBillCalculatorScreenState createState() => _SharedBillCalculatorScreenState();
}

class _SharedBillCalculatorScreenState extends State<SharedBillCalculatorScreen> {
  int numberOfPeople = 1;
  double billTotal = 0.0;
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Map<String, double> payerAmounts = {};
  Map<String, double> payerToPay = {};

  void calculateBill() {
    if (numberOfPeople > 0 && billTotal > 0 && payerAmounts.isNotEmpty) {
      double totalPaid = 0;

      for (String payer in payerAmounts.keys) {
        totalPaid += payerAmounts[payer]!;
      }

      double individualShare = billTotal / numberOfPeople;
      double remainingBalance = billTotal - totalPaid;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bill Calculation Results'),
            content: Column(
              children: [
              Text('Individual Share: \$${individualShare.toStringAsFixed(2)}'),
              for (String payer in payerAmounts.keys) ...[
                if (payerToPay[payer] != null && payerToPay[payer]! < 0)
                  Text('$payer needs to pay 0.00'),
                Text('$payer needs to pay ${payerToPay[payer]?.toStringAsFixed(2) ?? '0.00'}'),
                if (payerToPay[payer] != null && payerToPay[payer]! < 0)
                  Text('${numberOfPeople - payerAmounts.length} people need to split pay $payer ${payerToPay[payer]}'),
              ],
              Text('Remaining balance: \$${remainingBalance.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void editPayer(String payer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Payer'),
          content: Column(
            children: [
              TextField(
                controller: nameController..text = payer,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: amountController..text = payerAmounts[payer]?.toString() ?? '0.00',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (name.isNotEmpty && amount > 0) {
                  setState(() {
                    payerAmounts.remove(payer);
                    payerToPay.remove(payer);
                    payerAmounts[name] = amount;
                    payerToPay[name] = 0.0;
                    nameController.clear();
                    amountController.clear();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared Bill Calculator'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Number of People'),
            DropdownButton<int>(
              value: numberOfPeople,
              items: List.generate(10, (index) => index + 1)
                  .map((number) => DropdownMenuItem<int>(
                        value: number,
                        child: Text('$number'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  numberOfPeople = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Bill Total'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  billTotal = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Enter Payers and Amounts'),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Amount'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final name = nameController.text;
                        final amount = double.tryParse(amountController.text) ?? 0.0;

                        if (name.isNotEmpty && amount > 0) {
                          setState(() {
                            payerAmounts[name] = amount;
                            payerToPay[name] = 0.0; // Initialize to zero for now.
                            nameController.clear();
                            amountController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Column(
                  children: payerAmounts.keys.map((payer) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(payer),
                        ),
                        Expanded(
                          child: Text(payerAmounts[payer]?.toStringAsFixed(2) ?? '0.00'),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            editPayer(payer);
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: calculateBill,
              child: Text('Calculate Bill'),
            ),
          ],
        ),
      ),
    );
  }
}
