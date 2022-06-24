#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <chrono>

using namespace std;
using us = std::chrono::microseconds;

struct edges_t {
       unsigned short*  vertices1= new unsigned short[819306];
       unsigned short*  vertices2= new unsigned short[819306];
} edges;

void print_coloring(unsigned short* colors, int vert_num) {
    for (int j=0;j<vert_num;j++){
        cout<<"Vertex"<<j+1<<" ---> Color: "<<colors[j]<<endl;
    }
}

void better_coloring (int vert_num, int edge_num, edges_t edges) {
    unsigned short colors[50515];
    unsigned short d = 0;
    for (int i=0;i<vert_num;i++){
        colors[i]=0;
    }
    for (int i=0; i<edge_num;i++){
        unsigned short col_v1 = colors[edges.vertices1[i]];
        unsigned short col_v2 = colors[edges.vertices2[i]];
        if( col_v1 == col_v2){
            if(col_v2 != d){
                colors[edges.vertices2[i]] = d;
            }
            else{
                colors[edges.vertices2[i]] = d+1;
                d++;
            }
        }
    }
    //print_coloring(colors, vert_num);
}

int main() {
    string fname = "artist_edges.csv";
    int const vert_num = 50515;
    int const edge_num = 819306;
    string line, word;
    vector<string> row;
    fstream file (fname, ios::in);
    if(file.is_open()) {
        int index = 0;
        while(getline(file, line)) {
            row.clear();
            stringstream str(line);
            while(getline(str, word, ',')){
                row.push_back(word);
            }
            if (isdigit(row[0][0])){
                unsigned short v1 = stoi(row[0]);
                unsigned short v2 = stoi(row[1]);
                //cout<<v1<<"-"<<v2<<endl;
                edges.vertices1[index] = v1;
                edges.vertices2[index] = v2;
                index++;
            }
        }
    }
    else {
        cout<<"Could not open the file\n";
    }

    auto const benchmark_trials = 1000;
    auto const start_time = std::chrono::system_clock::now();
    for( int i = 0; i < benchmark_trials; i++ )
        better_coloring(vert_num, edge_num, edges);
    auto const end_time = std::chrono::system_clock::now();
    auto elapsed_time = std::chrono::duration_cast< us >( end_time - start_time );
    std::cout << "average time per run: "
              << elapsed_time.count() / static_cast< float >( benchmark_trials )
              << " us" << std::endl;
        
    return 0;
}