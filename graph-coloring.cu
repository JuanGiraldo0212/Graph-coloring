#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <chrono>
#include <omp.h>
#include <algorithm>
#include <cassert>

using namespace std;
using us = std::chrono::microseconds;

auto constexpr BLOCK_SIZE = 256u;

bool check_empty(unsigned short* re_color, int vert_num){
    auto count = 0;
    for (int i=0; i<vert_num; i++){
         count+=re_color[i];
    }

    return count == 0;
}

void print_coloring(unsigned short* colors, int vert_num) {
    for (int j=0;j<vert_num;j++){
        cout<<"Vertex"<<j<<" ---> Color: "<<colors[j]<<endl;
    }
}

void print_adj_list(vector<int> vertices[], int vert_num){
    for(int i=0; i<vert_num;i++){
        vector<int> curr = vertices[i];
        cout<<"Vertex:"<<i<<endl;
        for (auto j = 0lu; j < curr.size(); j++)
        {
            cout<<curr[j]<<" ";
        }
        cout<<endl;
    }
}

void better_coloring (int vert_num, vector<unsigned short> vertices []) {
    unsigned short* colors = new unsigned short[vert_num]();
    unsigned short* re_color = new unsigned short[vert_num]();
    for (int i=0; i<vert_num; i++){
        re_color[i] = 1;
    }
    while(!check_empty(re_color, vert_num)){
        #pragma omp parallel for
        for (int i=0; i<vert_num;i++){
            if (re_color[i] == 1){
                auto const ad_len = vertices[i].size();
                short* f_col = new short[vert_num];
                for(int j=0;j<vert_num;j++){
                    f_col[j] = -1;
                }
                
                for (auto j=0lu; j<ad_len; j++){
                    auto& adj_index = vertices[i][j];
                    f_col[colors[adj_index]]=i;
                }
                unsigned short j=0;
                bool stop = false;
                //cout<<i<<endl;
                while(!stop){
                    stop = (f_col[j] != i);
                    j++;
                }
                colors[i] = j-1;
                re_color[i] = 0;
                delete [] f_col;
            }  
        }
        /*
        for (int i =0; i<vert_num;i++){
            cout<<re_color[i]<<" ";
        }
        */
        //cout<<endl;

        #pragma omp parallel for
        for (int i=0; i<vert_num;i++){   
            auto const ad_len = vertices[i].size();
            for (auto j=0lu; j<ad_len; j++){
                auto& adj_index = vertices[i][j];
                if ((colors[i] == colors[adj_index]) && (i > adj_index)){
                    re_color[i] = 1;
                    //cout<<"entra"<<endl;
                }
            }
        }

    }
    delete [] re_color;
    print_coloring(colors, vert_num);
    cout<<"-------------"<<endl;
    delete [] colors;
}

__global__
void parallel_coloring(unsigned short * out, vector<unsigned short> *dev_data, size_t vert) {
    auto const th_id =  blockIdx.x * blockDim.x + threadIdx.x;
    if (th_id == 0) {
        for (int i=0; i<vert;i++){
            cout<<dev_data[i][0]<<endl;
        }
    }
}

int main( int argc, char ** argv) {

    string fname = "test_graph_2.csv";
    unsigned short const vert_num = 20;
    vector<unsigned short> vertices [vert_num];
    for (int i=0; i<vert_num;i++){
        vector<unsigned short> temp;
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
                unsigned short v1 = stoi(row[0]);
                unsigned short v2 = stoi(row[1]);
                vertices[v1].push_back(v2);
                vertices[v2].push_back(v1);
            }
        }
    }
    else {
        cout<<"Could not open the file\n";
    }

    unsigned short colors[vert_num]; 

    vector<unsigned short> *dev_data;
    unsigned short *dev_output;
    cudaMalloc((void**) &dev_data, sizeof(void *) * vert_num);
    cudaMalloc((void**) &dev_output, sizeof(unsigned short)*vert_num);

    cudaMemcpy( dev_data, vertices, sizeof(void *)*vert_num, cudaMemcpyHostToDevice);

    parallel_coloring<<< 1, BLOCK_SIZE >>>( dev_output, dev_data, vert_num);

    cudaMemcpy( colors, dev_output, sizeof(unsigned short)*vert_num, cudaMemcpyDeviceToHost);
    
    /*
    auto const benchmark_trials = 10000;
    auto const start_time = std::chrono::system_clock::now();
    for( int i = 0; i < benchmark_trials; i++ )
        better_coloring(vert_num, vertices);
    auto const end_time = std::chrono::system_clock::now();
    auto elapsed_time = std::chrono::duration_cast< us >( end_time - start_time );
    std::cout << "average time per run: "
            << elapsed_time.count() / static_cast< float >( benchmark_trials )
            << " us" << std::endl;
    */
    
    return 0;
}