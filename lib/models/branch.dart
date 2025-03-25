class Branch {
  final String coordinator;
  final String branch;
  final List parishes;
  Branch({
    required this.coordinator,
    required this.branch,
    required this.parishes,
  });
  factory Branch.getData(Map<String, dynamic> data) {
    return Branch(
      coordinator: data['id'].split(" -- ")[0],
      branch: data['id'].split(" -- ")[1],
      parishes: data['parishes'],
    );
  }
  Map<String, dynamic> setData() {
    return {
      'coordinator': coordinator,
      'branch': branch,
      'parishes': parishes,
    };
  }
}
