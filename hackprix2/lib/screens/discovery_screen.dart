import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/models/organisation.dart';
import 'package:ecosnap_1/models/charity.dart';
import 'package:ecosnap_1/services/api_service.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ApiService _apiService = ApiService();
  
  List<Organisation> _organisations = [];
  List<Charity> _charities = [];
  late Future<void> _initScreenFuture;

  // Hardcoded data for Local Events
  final List<Map<String, dynamic>> _localEvents = [
    {
      "name": "Community Garden Cleanup",
      "subtitle": "Join us this Saturday!",
      "img": "https://placehold.co/100x100/E9D2F4/333333?text=E",
      "participants": 23,
      "progress": 0.7,
      "isJoined": false,
    },
    {
      "name": "Beach Sweep",
      "subtitle": "Help keep our shores clean.",
      "img": "https://placehold.co/100x100/F4D2D7/333333?text=B",
      "participants": 45,
      "progress": 0.4,
      "isJoined": false,
    }
  ];

  @override
  void initState() {
    super.initState();
    _initScreenFuture = _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        _apiService.listOrganizations(),
        _apiService.getJoinedOrganizationIds(),
        _apiService.listCharities(),
        _apiService.getJoinedCharityIds(),
      ]);

      final allOrgs = results[0] as List<Organisation>;
      final joinedOrgIds = results[1] as Set<String>;
      final allCharities = results[2] as List<Charity>;
      final joinedCharityIds = results[3] as Set<String>;

      for (var org in allOrgs) {
        org.isJoined = joinedOrgIds.contains(org.orgId);
      }
      for (var charity in allCharities) {
        charity.isJoined = joinedCharityIds.contains(charity.charityId);
      }

      if (mounted) {
        setState(() {
          _organisations = allOrgs;
          _charities = allCharities;
        });
      }
    } catch (e) {
      throw Exception("Failed to load discovery data: $e");
    }
  }

  void _joinOrganisation(Organisation organisation) async {
    if (organisation.isJoined) return;
    try {
      await _apiService.signupForOrganization(organisation.orgId);
      if (mounted) {
        setState(() {
          final index = _organisations.indexWhere((o) => o.orgId == organisation.orgId);
          if (index != -1) {
            _organisations[index].isJoined = true;
            _organisations[index] = Organisation(
              orgId: _organisations[index].orgId, name: _organisations[index].name,
              totalSignups: _organisations[index].totalSignups + 1,
              totalCustomCountSum: _organisations[index].totalCustomCountSum,
              isJoined: true,
            );
          }
        });
      }
    } catch (e) { /* Handle error */ }
  }

  void _joinCharity(Charity charity) async {
    if (charity.isJoined) return;
    try {
      await _apiService.signupForCharity(charity.charityId);
      if (mounted) {
        setState(() {
          final index = _charities.indexWhere((c) => c.charityId == charity.charityId);
          if (index != -1) {
            _charities[index].isJoined = true;
            _charities[index] = Charity(
              charityId: _charities[index].charityId, name: _charities[index].name,
              totalSignups: _charities[index].totalSignups + 1,
              isJoined: true,
            );
          }
        });
      }
    } catch (e) { /* Handle error */ }
  }

  void _joinLocalEvent(int index) {
    setState(() {
      _localEvents[index]['isJoined'] = true;
      _localEvents[index]['participants'] += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: white,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildAppBarIcon(Icons.person_outline, color: primary),
              const SizedBox(width: 10),
              _buildAppBarIcon(Icons.search),
            ],
          ),
          const Text("Discover",
              style: TextStyle(
                  fontSize: 18, color: black, fontWeight: FontWeight.bold)),
          _buildAppBarIcon(Icons.person_add_outlined),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: white.withOpacity(0.95),
      ),
      child: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<void>(
              future: _initScreenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(),
                  ));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                
                // Build the UI once all data is loaded
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    if (_organisations.isNotEmpty) _buildOrganisationSection(),
                    const SizedBox(height: 25),
                    _buildLocalEventsSection(),
                    const SizedBox(height: 25),
                    if (_charities.isNotEmpty) _buildCharitySection(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganisationSection() {
    return _buildSection(
      title: "Organisations",
      itemCount: _organisations.length,
      itemBuilder: (context, index) {
        final item = _organisations[index];
        return _buildComplexListItem(
          imageUrl: 'https://placehold.co/100x100/A9D9C8/333333?text=${item.name.isNotEmpty ? item.name[0] : 'O'}',
          name: item.name,
          subtitle: "${item.totalSignups} members",
          progress: (item.totalSignups % 10) / 10.0,
          participantCount: item.totalSignups,
          actionButton: _buildActionButton(
            icon: item.isJoined ? Icons.check : Icons.add,
            text: item.isJoined ? "Joined" : "Join",
            onTap: () => _joinOrganisation(item),
            isJoined: item.isJoined,
          ),
        );
      },
    );
  }

  Widget _buildLocalEventsSection() {
    return _buildSection(
      title: "Local Events",
      itemCount: _localEvents.length,
      itemBuilder: (context, index) {
        final item = _localEvents[index];
        return _buildComplexListItem(
          imageUrl: item['img'],
          name: item['name'],
          subtitle: item['subtitle'],
          progress: item['progress'],
          participantCount: item['participants'],
          actionButton: _buildActionButton(
            icon: item['isJoined'] ? Icons.check : Icons.event,
            text: item['isJoined'] ? "Attending" : "Attend",
            onTap: () => _joinLocalEvent(index),
            isJoined: item['isJoined'],
          ),
        );
      },
    );
  }

  Widget _buildCharitySection() {
    return _buildSection(
      title: "Charities",
      itemCount: _charities.length,
      itemBuilder: (context, index) {
        final item = _charities[index];
        return _buildComplexListItem(
          imageUrl: 'https://placehold.co/100x100/F4E3D2/333333?text=${item.name.isNotEmpty ? item.name[0] : 'C'}',
          name: item.name,
          subtitle: "${item.totalSignups} supporters",
          progress: (item.totalSignups % 10) / 10.0,
          participantCount: item.totalSignups,
          actionButton: _buildActionButton(
            icon: item.isJoined ? Icons.favorite : Icons.favorite_border,
            text: item.isJoined ? "Supported" : "Support",
            onTap: () => _joinCharity(item),
            isJoined: item.isJoined,
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18, color: black, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: white,
            boxShadow: [
              BoxShadow(
                  color: darkGrey.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 5)
            ],
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: (context, index) => const Divider(
                thickness: 0.5, height: 1, indent: 20, endIndent: 20),
          ),
        )
      ],
    );
  }

  Widget _buildComplexListItem({
    required String imageUrl,
    required String name,
    required String subtitle,
    required double progress,
    int? participantCount,
    required Widget actionButton,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(imageUrl: imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: black.withOpacity(0.6))),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              actionButton,
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (participantCount != null) ...[
                const SizedBox(width: 15),
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(participantCount.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAvatar({required String imageUrl}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String text,
      required VoidCallback onTap,
      required bool isJoined}) {
    return GestureDetector(
      onTap: isJoined ? null : onTap, // Disable tap if already joined
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color:
              isJoined ? Colors.green.shade400 : Colors.grey.withOpacity(0.15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isJoined ? white : black),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isJoined ? white : black)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, {Color? color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: black.withOpacity(0.08)),
      child: Icon(icon, color: color ?? darkGrey, size: 23),
    );
  }
}
