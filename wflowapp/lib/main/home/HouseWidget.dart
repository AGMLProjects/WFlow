import 'package:flutter/material.dart';
import 'package:wflowapp/main/home/model/House.dart';

class HouseWidget extends StatelessWidget {
  HouseWidget({super.key, required this.house});

  final House house;

  @override
  Widget build(BuildContext context) {
    if (house.name.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/addHouse');
        },
        child: Container(
          width: 500.0,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(
              Icons.add,
              color: Colors.grey,
              size: 40.0,
            ),
          ),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 20.0,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/house', arguments: {
            'id': house.house_id,
            'name': house.name,
            'city': house.city,
            'address': house.address,
            'type': house.house_type
          });
        },
        child: Container(
          width: 500.0,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [house.color!, Colors.white],
                    )),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          house.name,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                height: 40,
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      house.city,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 40,
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      house.address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                alignment: Alignment.centerLeft,
                height: 40,
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Water consumes: ',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${house.total_liters} L',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 40,
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Color.fromARGB(255, 255, 94, 0)),
                    const SizedBox(width: 8),
                    const Text(
                      'Gas consumes: ',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${house.total_gas} m3',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
