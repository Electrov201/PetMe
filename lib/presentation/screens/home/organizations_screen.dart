import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationsScreen extends StatelessWidget {
	const OrganizationsScreen({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Organizations'),
				actions: [
					IconButton(
						icon: const Icon(Icons.search),
						onPressed: () {
							// TODO: Implement search
						},
					),
				],
			),
			body: StreamBuilder<QuerySnapshot>(
				stream: FirebaseFirestore.instance.collection('organizations').snapshots(),
				builder: (context, snapshot) {
					if (snapshot.hasError) {
						return const Center(child: Text('Something went wrong'));
					}

					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator());
					}

					return ListView.builder(
						padding: const EdgeInsets.all(16),
						itemCount: snapshot.data!.docs.length,
						itemBuilder: (context, index) {
							final org = snapshot.data!.docs[index];
							return OrganizationCard(
								name: org['name'] ?? '',
								description: org['description'] ?? '',
								address: org['address'] ?? '',
								imageUrl: org['imageUrl'] ?? '',
								phone: org['phone'] ?? '',
								email: org['email'] ?? '',
							);
						},
					);
				},
			),
		);
	}
}

class OrganizationCard extends StatelessWidget {
	final String name;
	final String description;
	final String address;
	final String imageUrl;
	final String phone;
	final String email;

	const OrganizationCard({
		Key? key,
		required this.name,
		required this.description,
		required this.address,
		required this.imageUrl,
		required this.phone,
		required this.email,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.only(bottom: 16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					if (imageUrl.isNotEmpty)
						Image.network(
							imageUrl,
							height: 200,
							width: double.infinity,
							fit: BoxFit.cover,
						),
					Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									name,
									style: Theme.of(context).textTheme.titleLarge,
								),
								const SizedBox(height: 8),
								Text(
									description,
									style: Theme.of(context).textTheme.bodyMedium,
									maxLines: 3,
									overflow: TextOverflow.ellipsis,
								),
								const SizedBox(height: 16),
								Row(
									children: [
										const Icon(Icons.location_on, size: 16),
										const SizedBox(width: 8),
										Expanded(
											child: Text(
												address,
												style: Theme.of(context).textTheme.bodySmall,
											),
										),
									],
								),
								const SizedBox(height: 8),
								Row(
									children: [
										TextButton.icon(
											icon: const Icon(Icons.phone),
											label: const Text('Call'),
											onPressed: () {
												// TODO: Implement call functionality
											},
										),
										TextButton.icon(
											icon: const Icon(Icons.email),
											label: const Text('Email'),
											onPressed: () {
												// TODO: Implement email functionality
											},
										),
									],
								),
							],
						),
					),
				],
			),
		);
	}
}