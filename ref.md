```cpp
struct package_ref {
	static package_ref create(string pkg_spec);

	string name;
	string type;

	union {
		string path;

		struct {
			string path;
			string git;
			string ref;
		};
	};
};

struct manifest {
	static manifest load(string file_path);

	string name;
	string description;
	string version;
	map<string, package_ref> dependencies;
	map<string, package_ref> dev_dependencies;
	map<string, string> features;
	vector<string> include_files;
	vector<string> exclude_files;
};

struct package {
	static package load(string file_path);

	string path;
	manifest manifest;
	vector<string> wanted_by;
};

struct package_cache {
	static package_cache create(string path);

	void checkout(package_ref& pkg);
	void download(string pkg_name, string repo_url);
	void fetch(string pkg_name);

	string path;
};

struct package_graph {
	static package_graph create(package_ref& root, string cache_path);

	void add(package_ref& pkg, string wanted_by);

	package_cache cache
	vector<package> packages;
};
```
