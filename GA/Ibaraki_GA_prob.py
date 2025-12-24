from deap import base
from deap import creator
from deap import tools
from deap import algorithms
import requests
import json
import random
import time
import numpy as np
import os, sys
sys.path.append(os.environ['OACIS_ROOT'])
import oacis

# LINE Messaging APIのチャンネルアクセストークン
CHANNEL_ACCESS_TOKEN = 'dAP92XoovKW3HqK6Ck2IR+7kq0YHLD70NSPyPHh2I2luwTRcGnei3Fsbo8h+AZYEm3ouPtINbtfo6L2dsxc+2rdyykdR7ShulM1qoQZiFneUrOdcrK2dMXWeqVxHc6KTOUXOMrY97BRcHk0W9vq/0wdB04t89/1O/w1cDnyilFU='

# メッセージを送信したいユーザーのID
# グループIDや部屋IDでも可能
TO_USER_ID = 'Uecdc9a317db272651e0a4f9ef6539513' #自分

# LINE Messaging APIのプッシュメッセージ送信エンドポイント
API_ENDPOINT = 'https://api.line.me/v2/bot/message/push'

# 最小化？最大化？
creator.create("FitnessMin", base.Fitness, weights=(-1.0,))

# 個体の定義
creator.create("Individual", list, fitness=creator.FitnessMin)

toolbox = base.Toolbox()
# 各個体の遺伝子の中身を決める関数
toolbox.register("attr_bool", random.randint, 0, 1)
# 個体に含まれる遺伝子の数
# 2ビットペア110組(220ビット) + to_per_cycle 16個×3ビット(48ビット) + prob_load 7個×6ビット(42ビット) = 310ビット
toolbox.register("individual", tools.initRepeat, creator.Individual, toolbox.attr_bool, n=310)

# 集団の個体数を設定するための関数
toolbox.register("population", tools.initRepeat, list, toolbox.individual)
# 次世代に子を残す親を選択する方法
toolbox.register("select", tools.selTournament, tournsize=3)
# 交叉関数
toolbox.register("mate", tools.cxTwoPoint)
# 突然変異関数（indpb=遺伝子が突然変異を起こす確率)
toolbox.register("mutate", tools.mutFlipBit, indpb=0.1)

def register_Runs(individuals):
    sim = oacis.Simulator.find_by_name("Ibaraki_GA_prob")
    host = oacis.Host.find_by_name("localhost")

    for individual in individuals:
        # 遺伝子の最初の220個を2個ずつ取り出し、10進数に変換して結合
        params = {}
        o_list_string = ""
        for i in range(110):  # 110ペア (220個の遺伝子を2個ずつ)
            binary_value = individual[i*2:(i+1)*2]
            if not binary_value or len(binary_value) != 2:
                raise ValueError(f"Invalid binary_value length at o_list_string index {i}: {binary_value} (individual length: {len(individual)})")
            decimal_value = int("".join(map(str, binary_value)), 2)
            o_list_string += str(decimal_value)

        # o_list_stringをparamsに追加
        params["o_list_string"] = o_list_string

        # 続く48個を3個ずつに分割し、cycle_1～cycle_16に登録
        for i in range(16):
            binary_value = individual[220 + i*3:220 + (i+1)*3]
            if not binary_value or len(binary_value) != 3:
                raise ValueError(f"Invalid binary_value length at cycle_{i+1}: {binary_value} (individual length: {len(individual)})")
            decimal_value = int("".join(map(str, binary_value)), 2)
            params[f"to_per_cycle_{i+1}"] = decimal_value

        # 残りの42個を6個ずつに分割し、prob_load_1～prob_load_7に登録 (0-63を0.0-20.0に線形マップ)
        for i in range(7):
            binary_value = individual[268 + i*6:268 + (i+1)*6]
            if not binary_value or len(binary_value) != 6:
                raise ValueError(f"Invalid binary_value length at prob_load_{i+1}: {binary_value} (individual length: {len(individual)})")
            decimal_value = int("".join(map(str, binary_value)), 2)
            prob_value = (decimal_value / 63.0) * 20.0
            params[f"prob_load_{i+1}"] = prob_value

        # パラメータセットをOACISに登録
        ps = sim.find_or_create_parameter_set(params)
        ps.find_or_create_runs_upto(1, submitted_to=host)

def notify_smartphone(message_text):
    """
    LINEに通知を送信する関数
    :param message_text: 送信するメッセージの内容
    """
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {CHANNEL_ACCESS_TOKEN}'
    }

    payload = {
        'to': TO_USER_ID,
        'messages': [
            {
                'type': 'text',
                'text': message_text
            }
        ]
    }

    try:
        response = requests.post(API_ENDPOINT, headers=headers, data=json.dumps(payload))
        if response.status_code == 200:
            print('LINE通知の送信に成功しました。')
        else:
            print(f'LINE通知の送信に失敗しました。ステータスコード: {response.status_code}')
            print(f'エラー詳細: {response.text}')
    except requests.exceptions.RequestException as e:
        print(f'LINE通知の送信中にエラーが発生しました: {e}')


def eval_Ibaraki_complex(individual):
    sim = oacis.Simulator.find_by_name("Ibaraki_GA_prob")
    host = oacis.Host.find_by_name("localhost")

    # 遺伝子の最初の220個を2個ずつ取り出し、10進数に変換して結合
    params = {}
    o_list_string = ""
    for i in range(110):  # 110ペア (220個の遺伝子を2個ずつ)
        binary_value = individual[i*2:(i+1)*2]
        if not binary_value or len(binary_value) != 2:
            raise ValueError(f"Invalid binary_value length at o_list_string index {i}: {binary_value} (individual length: {len(individual)})")
        decimal_value = int("".join(map(str, binary_value)), 2)
        o_list_string += str(decimal_value)

    # o_list_stringをparamsに追加
    params["o_list_string"] = o_list_string

    # 続く48個を3個ずつに分割し、cycle_1～cycle_16に登録
    for i in range(16):
        binary_value = individual[220 + i*3:220 + (i+1)*3]
        if not binary_value or len(binary_value) != 3:
            raise ValueError(f"Invalid binary_value length at cycle_{i+1}: {binary_value} (individual length: {len(individual)})")
        decimal_value = int("".join(map(str, binary_value)), 2)
        params[f"to_per_cycle_{i+1}"] = decimal_value

    # 残りの42個を6個ずつに分割し、prob_load_1～prob_load_7に登録 (0-63を0.0-20.0に線形マップ)
    for i in range(7):
        binary_value = individual[268 + i*6:268 + (i+1)*6]
        if not binary_value or len(binary_value) != 6:
            raise ValueError(f"Invalid binary_value length at prob_load_{i+1}: {binary_value} (individual length: {len(individual)})")
        decimal_value = int("".join(map(str, binary_value)), 2)
        prob_value = (decimal_value / 63.0) * 20.0
        params[f"prob_load_{i+1}"] = prob_value

    # パラメータセットをOACISに登録
    ps = sim.find_or_create_parameter_set(params)
    ps.find_or_create_runs_upto(1, submitted_to=host)

    fail_count = 0  # 失敗回数をカウントする変数

    # 全部の実行の終了を待つ場所
    while True:
        ps = sim.find_or_create_parameter_set(params)
        run = ps.runs().first()
        if run is not None and run.status() == "finished":
            result = run.result()
            if result is not None:
                print(f"Evaluation completed for individual: {individual}")
                print("Result: ", result["probability_result_list"], result["evaluation_function"])
                return float(result["evaluation_function"]),
            else:
                print("Run finished but result is not ready. Waiting...")
        elif run is not None and run.status() == "failed":
            fail_count += 1
            print(f"Run failed ({fail_count} times), deleting the run and retrying.")
            run.delete()
            if fail_count < 3:
                print("Retrying...")
                ps.find_or_create_runs_upto(1, submitted_to=host)
            else:
                print("Exceeded max fail attempts. Exiting.")
                notify_smartphone("シミュレーションが失敗しました。最大試行回数を超えました。")
                sys.exit(1)
        elif run is None:
            print("Run is None, waiting for the run to be created.")
        time.sleep(5)

toolbox.register("evaluate", eval_Ibaraki_complex)

# アルゴリズムのパラメータ設定
NGEN = 50  # 何世代まで行うか
POP = 80  # 集団の個体数
CXPB = 0.7  # 交叉確率
MUTPB = 0.1  # 個体が突然変異を起こす確率

def main():
    random.seed(39)
    pop = toolbox.population(n=POP)
    register_Runs(pop)
    print("Start of evolution")

    fitnesses = list(map(toolbox.evaluate, pop))
    for ind, fit in zip(pop, fitnesses):
        ind.fitness.values = fit

    print("  Evaluated %i individuals" % len(pop))

    # 世代ごとの統計を記録するリスト
    stats_log = []

    for g in range(NGEN):
        print("-- Generation %i --" % g)

        offspring = toolbox.select(pop, len(pop))
        offspring = list(map(toolbox.clone, offspring))

        for child1, child2 in zip(offspring[::2], offspring[1::2]):
            if random.random() < CXPB:
                toolbox.mate(child1, child2)
                del child1.fitness.values
                del child2.fitness.values

        for mutant in offspring:
            if random.random() < MUTPB:
                toolbox.mutate(mutant)
                del mutant.fitness.values

        invalid_ind = [ind for ind in offspring if not ind.fitness.valid]
        register_Runs(invalid_ind)

        fitnesses = map(toolbox.evaluate, invalid_ind)

        for ind, fit in zip(invalid_ind, fitnesses):
            ind.fitness.values = fit

        print("  Evaluated %i individuals" % len(invalid_ind))

        pop[:] = offspring

        fits = [ind.fitness.values[0] for ind in pop]
        length = len(pop)
        mean = sum(fits) / length
        min_fit = min(fits)
        max_fit = max(fits)

        print("  Min %s" % min(fits))
        print("  Max %s" % max(fits))
        print("  Avg %s" % mean)

        # 世代ごとの最小値・最大値・平均値を保存
        stats_log.append((g, min_fit, max_fit, mean))
        
        # 20世代ごとに通知
        if g == 0 or (g + 1) % 20 == 0:
            notify_smartphone(f"第{g + 1}世代が終了しました。最小値: {min_fit}, 最大値: {max_fit}, 平均値: {mean}")

    print("-- End of (successful) evolution --")
    # 各世代の実行結果を最後に再度出力
    print("=== Generation Statistics ===")
    for (gen, min_val, max_val, avg_val) in stats_log:
        print("Generation {} -> Min: {}, Max: {}, Avg: {}".format(gen, min_val, max_val, avg_val))

    best_ind = tools.selBest(pop, 1)[0]
    print("Best individual is %s, %s" % (best_ind, best_ind.fitness.values))

    # 最良個体のパラメータを計算して出力
    best_params = {}

    # o_list_string 再構築
    best_o_list_string = ""
    for i in range(110):
        binary_value = best_ind[i*2:(i+1)*2]
        decimal_value = int("".join(map(str, binary_value)), 2)
        best_o_list_string += str(decimal_value)
    best_params["o_list_string"] = best_o_list_string

    # to_per_cycle_1～16
    for i in range(16):
        binary_value = best_ind[220 + i*3:220 + (i+1)*3]
        decimal_value = int("".join(map(str, binary_value)), 2)
        best_params[f"to_per_cycle_{i+1}"] = decimal_value

    # prob_load_1～7
    for i in range(7):
        binary_value = best_ind[268 + i*6:268 + (i+1)*6]
        decimal_value = int("".join(map(str, binary_value)), 2)
        prob_value = (decimal_value / 63.0) * 20.0
        best_params[f"prob_load_{i+1}"] = prob_value

    print("Best individual's params:")
    print(best_params)

    # 正常終了時の通知
    notify_smartphone("シミュレーションが正常に終了しました。最良個体の評価値: {}".format(best_ind.fitness.values))

if __name__ == "__main__":
    main()
