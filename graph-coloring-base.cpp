#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <chrono>

using namespace std;
using us = std::chrono::microseconds;

void print_coloring(vector<int> colors) {
    for (int j=0;j<colors.size();j++){
        cout<<"Vertex"<<j+1<<" ---> Color: "<<colors[j]<<endl;
    }
}

void better_coloring (int vert_num, vector<int> vertices []) {
    vector<int> colors;
    int d = 0;
    for (int i=0;i<vert_num;i++){
        colors.push_back(0);
    }
    for (int i=0; i<vert_num;i++){
        vector<int> const &curr = vertices[i];
        for (int j=0; j<curr.size();j++){
            if(colors[i] == colors[curr[j]]){
                if(colors[curr[j]] != d){
                    colors[curr[j]] = d;
                }
                else{
                    colors[curr[j]] = d+1;
                    d++;
                }
            }
        }
    }
    //print_coloring(colors);
}

int main() {

    string fname = "artist_edges.csv";
    int const vert_num = 50515;
    vector<int> vertices [vert_num];
    for (int i=0; i<vert_num;i++){
        vector<int> temp;
        vertices[i] = temp;
    }
    string line, word;
    vector<string> row;
    fstream file (fname, ios::in);
    if(file.is_open()) {
        while(getline(file, line)) {
            row.clear();
            stringstream str(line);
            while(getline(str, word, ',')){
                row.push_back(word);
            }
            if (isdigit(row[0][0])){
                int v1 = stoi(row[0]);
                int v2 = stoi(row[1]);
                vertices[v1].push_back(v2);
            }
        }
    }
    else {
        cout<<"Could not open the file\n";
    }

    auto const benchmark_trials = 1000;
    auto const start_time = std::chrono::system_clock::now();
    for( int i = 0; i < benchmark_trials; i++ )
        better_coloring(vert_num, vertices);
    auto const end_time = std::chrono::system_clock::now();
    auto elapsed_time = std::chrono::duration_cast< us >( end_time - start_time );
    std::cout << "average time per run: "
              << elapsed_time.count() / static_cast< float >( benchmark_trials )
              << " us" << std::endl;
    return 0;
}