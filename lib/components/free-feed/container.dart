import 'package:flutter/material.dart';

class FreeFeed extends StatefulWidget {
  @override
  _FreeFeedState createState() => _FreeFeedState();
}

class _FreeFeedState extends State<FreeFeed> {

  final List<Map<String, String>> pets = [
    {
      "name": "Puppy Max",
      "location": "New-York, USA",
      "price": "\$200",
      "image": "https://i.imgur.com/30wOxPJ.jpeg",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
  ];


  Widget _buildForYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Pour vous",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Voir tout",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemCount: pets.length,
          itemBuilder: (_, index) {
            final pet = pets[index];
            return _buildPetCard(pet);
          },
        ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, String> pet) {
    return Container(
      width: 160,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  pet["image"]!,
                  height: 184,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  child: Icon(
                    Icons.favorite_border,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pet["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pet["location"]!,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pet["price"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildForYouSection();
  }

}