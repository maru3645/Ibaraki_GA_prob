/**
* Name: Administrator
* Based on the internal empty template. 
* Author: seo
* Tags: 
*/


model Administrator

/* Insert your model definition here */

import "./Main.gaml"

global {
	int check_difference <- 0;
	list result_num;
	list difference_list;
	list<int> probability_data <- [31,55,14,2,92,6,0,0,0,4,92,4, 0,94,6,44,0,56,7,93,0, 8,83,9,11,79,10,9,82,9,25,60,15, 34,66,0,0,71,29,40,0,60,0,0,0, 33,46,21,0,90,10,0,0,0,9,91,0, 32,7,67,20,79,1,39,31,30,1,84,15, 10,70,20,30,67,3,5,80,15,14,67,19];//地点１−Aから右折直進左折の順番
	list<float> float_probability_data <- [0.31, 0.55, 0.14, 0.02, 0.92, 0.06, 0.0, 0.0, 0.0, 0.04, 0.92, 0.04,
                     0.0, 0.94, 0.06, 0.44, 0.0, 0.56, 0.07, 0.93, 0.0, 0.08, 0.83, 0.09,
                     0.11, 0.79, 0.10, 0.09, 0.82, 0.09, 0.25, 0.60, 0.15, 0.34, 0.66, 0.0,
                     0.0, 0.71, 0.29, 0.40, 0.0, 0.60, 0.0, 0.0, 0.0, 0.33, 0.46, 0.21,
                     0.0, 0.90, 0.10, 0.0, 0.0, 0.0, 0.09, 0.91, 0.0, 0.32, 0.07, 0.67,
                     0.20, 0.79, 0.01, 0.39, 0.31, 0.30, 0.01, 0.84, 0.15, 0.10, 0.70,
                     0.20, 0.30, 0.67, 0.03, 0.05, 0.80, 0.15, 0.14, 0.67, 0.19];
    
    list<int> actual_data <- [404, 2504, 314, 2544, 2445, 520, 2505, 3059, 2138, 3220, 2455, 526, 580, 266, 353, 1753, 333, 1767, 486, 1975, 304, 1789, 3244, 2133, 2675, 1966]; //実データを順番に入れる
	list<int> dummy_actual_data <- [612,3523,46,2962,2679,846,3523,2861,2757,2753,2679,846,841,24,58,582,104,569,841,1506,256,582,2753,1985,3418,1360]; //ダミー断面交通量データ
                     
    //ダミー用データ
    list<int> dummy_probability_data <- [1, 10, 91, 16, 85, 1, 0, 0, 0, 1, 99, 1, 0, 100, 1, 1, 0, 99, 2, 99, 0, 0, 0, 0, 1, 96, 5, 4, 97, 0, 0, 99, 0, 0, 100, 1, 29, 72, 0, 0, 99, 2, 25, 0, 75, 0, 0, 0, 14, 64, 23, 0, 92, 9, 0, 0, 0, 18, 83, 0, 5, 29, 67, 64, 33, 4, 60, 30, 12, 0, 99, 2, 1, 99, 1, 2, 69, 30, 23, 78, 1, 3, 94, 5];
    list<float> dummy_float_probability_data <- [0.003, 0.096, 0.901, 0.151, 0.846, 0.003, 0.0, 0.0, 0.0, 0.006, 0.992, 0.002, 0.0, 0.994, 0.006, 0.004, 0.0, 0.996, 0.015, 0.985, 0.0, 0.0, 0.0, 0.0, 0.003, 0.951, 0.046, 0.037, 0.963, 0.0, 0.0, 1.0, 0.0, 0.0, 0.999, 0.001, 0.286, 0.714, 0.0, 0.0, 0.985, 0.015, 0.25, 0.0, 0.75, 0.0, 0.0, 0.0, 0.14, 0.632, 0.228, 0.0, 0.912, 0.088, 0.0, 0.0, 0.0, 0.175, 0.825, 0.0, 0.048, 0.286, 0.667, 0.634, 0.327, 0.039, 0.591, 0.291, 0.118, 0.0, 0.988, 0.012, 0.004, 0.996, 0.001, 0.015, 0.685, 0.299, 0.226, 0.771, 0.003, 0.024, 0.932, 0.044];
	
	float evaluation_function; //最終的にGAで評価する関数（1/差の2乗）
	list probability_result_list;
	
	
	//ACO用変数
	list<int> dummy_data_float_check;
	
	//ACO時に利用する、チェックポイントのダミー実データ格納
	int dummy_volume_correct;
	
	//計測７地点の、ACO時の,evaluation_function比較用の、ダミーデータの右左折直進確立データ（地点１からそれぞれAから入って右折・直進・左折、　Bから入って右折・直進・左折、　Cから入って右折・直進・左折、　Dから入って右折・直進・左折の順番。ないときは０）
//	list<float> aco_dummy_prob <- [0.0, 0.167, 0.833, 0.699, 0.301, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.83, 0.17, 0.14, 0.0, 0.86, 0.127, 0.873, 0.0, 0.0, 0.0, 0.0, 0.052, 0.226, 0.722, 0.464, 0.536, 0.0, 0.027, 0.973, 0.0, 0.009, 0.97, 0.021, 0.046, 0.954, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.053, 0.706, 0.242, 0.0, 0.9, 0.1, 0.0, 0.0, 0.0, 0.141, 0.859, 0.0, 0.0, 0.074, 0.926, 0.264, 0.612, 0.124, 0.63, 0.205, 0.165, 0.0, 0.999, 0.001, 0.6, 0.0, 0.4, 0.051, 0.949, 0.0, 0.625, 0.121, 0.254, 0.0, 0.955, 0.045];
	list<float> aco_dummy_prob <- [0.0, 0.167, 0.833, 0.699, 0.301, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 
    0.0, 0.83, 0.17, 0.14, 0.0, 0.86, 0.127, 0.873, 0.0, 0.0, 0.0, 0.0, 
    0.052, 0.226, 0.722, 0.462, 0.538, 0.0, 0.027, 0.973, 0.0, 0.009, 0.97, 0.021, 
    0.046, 0.954, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
    0.053, 0.706, 0.242, 0.0, 0.9, 0.1, 0.0, 0.0, 0.0, 0.141, 0.859, 0.0, 
    0.0, 0.544, 0.456, 0.199, 0.463, 0.338, 0.63, 0.205, 0.165, 0.0, 0.999, 0.001, 
    0.359, 0.401, 0.24, 0.034, 0.689, 0.277, 0.625, 0.121, 0.254, 0.156, 0.806, 0.037];
}

species Administrator{
	init {
		
	}	
	
	reflex when:cycle = finish_cycle + 600{

		//今回はダミーの結果と比べる
		int b <- 1;
		loop a over:checkpoint_intersection{
			ask intersection where(each.index = a){
				write "-----------------------------------------------";
				write string(self.name) + "_地点：" + string(b);
				write "A："+ a_volume + "台";
				write "B："+ b_volume + "台";
				write "C："+ c_volume + "台";
				write "D："+ d_volume + "台";
				write "-----------------------------------------------";
				
				//断面交通量を比較し、differenceを更新
				dummy_volume_correct <- 0;
				if road_a != nil {
					loop i over:road_a {
						dummy_volume_correct <- dummy_volume_correct + road(i).dummy_volume;
					}
					difference <- difference + abs(dummy_volume_correct - a_volume);
					add a_volume to:result_num;
					add dummy_volume_correct - a_volume to:difference_list;
				}
				
				dummy_volume_correct <- 0;
				if road_b != nil {
					loop i over:road_b {
						dummy_volume_correct <- dummy_volume_correct + road(i).dummy_volume;
					}
					difference <- difference + abs(dummy_volume_correct - b_volume);
					add b_volume to:result_num;
					add dummy_volume_correct - b_volume to:difference_list;
				}
				
				dummy_volume_correct <- 0;
				if road_c != nil {
					loop i over:road_c {
						dummy_volume_correct <- dummy_volume_correct + road(i).dummy_volume;
					}
					difference <- difference + abs(dummy_volume_correct - c_volume);
					add c_volume to:result_num;
					add dummy_volume_correct - c_volume to:difference_list;
				}
				
				dummy_volume_correct <- 0;
				if road_d != nil {
					loop i over:road_d {
						dummy_volume_correct <- dummy_volume_correct + road(i).dummy_volume;
					}
					difference <- difference + abs(dummy_volume_correct - d_volume);
					add d_volume to:result_num;
					add dummy_volume_correct - d_volume to:difference_list;
				}		
			}
			b <- b + 1;
		}
		
		int c <- 1;
		
		//ここから右左折直進確立の比較（ACO時の新しいダミーデータ（complete））
		loop a over:checkpoint_intersection {
			write a;
			ask intersection where(each.index = a){
				loop i from:0 to:2 {
					if from_a_volume[i] != 0 {
						num_a[i] <- from_a_volume[i] / sum(from_a_volume);
					} else {
						num_a[i] <- from_a_volume[i];
					}				
				}
				
				loop i from:0 to:2 {
					if from_b_volume[i] != 0 {
						num_b[i] <- from_b_volume[i] / sum(from_b_volume);
					} else {
						num_b[i] <- from_b_volume[i];
					}
				}
				
				loop i from:0 to:2 {
					if from_c_volume[i] != 0 {
						num_c[i] <- from_c_volume[i] / sum(from_c_volume);
					} else {
						num_c[i] <- from_c_volume[i];
					}
				}
				
				loop i from:0 to:2 {
					if from_d_volume[i] != 0 {
						num_d[i] <- from_d_volume[i] / sum(from_d_volume);
					} else {
						num_d[i] <- from_d_volume[i];
					}
				}
				
				
				my_probability_result <- num_a + num_b + num_c + num_d; //各交差点ごとの確率
				
				
				probability_result_list <- probability_result_list + my_probability_result;
				
				//ダミーデータと比較
				loop j from:0 to:length(my_probability_result)-1 {
					if my_probability_result[j] - aco_dummy_prob[j] != 0.0 {
						evaluation_function <-  evaluation_function + ((100*my_probability_result[j] - 100*aco_dummy_prob[j])^2);
					} else {
						evaluation_function <-  evaluation_function + 0;
					}
					
				}
				
			}
			c <- c + 1;
		}
		
		write "seed : " + seed;
//		write "weight_value_list : " + weight_value_list;
		write "list_o_GA : " + list_o_ga;
//		write "to_per_cycle_list : " + to_per_cycle_list;
		ask intersection {
			write ["intersection" + id, a_volume, b_volume, c_volume, d_volume, from_a_volume[0], from_a_volume[1], from_a_volume[2], from_b_volume[0], from_b_volume[1], from_b_volume[2], from_c_volume[0], from_c_volume[1], from_c_volume[2], from_d_volume[0], from_d_volume[1], from_d_volume[2]];
		}
		ask road {
			write ["road"+ index, volume];
		}
		
		write "difference : " + difference;
		write "result_num : " + result_num;
		write "difference_list : " + difference_list;
		write "probability_result_list : " + probability_result_list;
		write "evaluation_function : " + evaluation_function;
		
		file oacisOutputJson <- json_file(pathWorkDirectory + "/_output.json" ,map([
			"difference"::difference,
			"result_num"::result_num,
			"difference_list"::difference_list,
			"probability_result_list"::probability_result_list,
			"evaluation_function"::evaluation_function
		]));
		save oacisOutputJson type:"json";
	}
}
