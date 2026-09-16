#include <bits/stdc++.h>
using namespace std;


int main(){
    int arr[]={1,1,1,3};
    int size=7;

    int k = 3;
    long long sum=arr[0];
    int left=0;
    int maxlen=0;

    int i=0;
    while(i<size){
        while(left<=i && sum>k){
            sum-=arr[left];
            left++;}

        if(sum==k){
            maxlen=max(maxlen,(i+1)-left);}

        i++;
        if(i<size) sum+=arr[i];
    }
    cout<<maxlen;
}