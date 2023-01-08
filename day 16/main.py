import enum
from io import TextIOWrapper
from itertools import islice
import itertools
import json
from typing import Any, Dict, List, Tuple, TypeVar
import re

import numpy as np


def main(f: TextIOWrapper) -> None:
    lines = [
        re.compile("^.*? (.*?) .*?=(\\d+).*?(?:(?:valves)|(?:valve)) ((?:\\w\\w)(?:, \\w\\w)*)$").findall(line)[0]
        for line in f.read().splitlines()
    ]
    valve_names = {name: index for index, (name, _, _) in enumerate(lines)}
    valves = [
        {
            "name": name,
            "flow_rate": int(flow_rate),
            "connections": [valve_names[valve] for valve in connections.split(", ")] + [valve_names[name]],
        }
        for name, flow_rate, connections in lines
    ]
    route_cost, routes = calculate_routes(valves)

    queue: List[Dict[str, Any]] = [
        {
            "new_valves": [valve1, valve2],
            "curr_valves": [valve_names["AA"], valve_names["AA"]],
            "curr_pressure": 0,
            "sum_pressure": 0,
            "open_valves": [],
        }
        for valve1, valve2 in itertools.product(range(len(valve_names)), range(len(valve_names)))
        if valve1 != valve_names["AA"] and valve2 != valve_names["AA"] and valve1 != valve2 and valve1 < valve2
    ]
    for i in range(26):
        # step all moves
        new_queue = []
        for move in queue:
            # update sum_pressure
            move["sum_pressure"] += move["curr_pressure"]
            if len(move["open_valves"]) >= len([1 for valve in valves if valve["flow_rate"] != 0]):
                new_queue.append(move)
                continue
            open_valves = [
                move["new_valves"][j] == move["curr_valves"][j] and move["new_valves"][j] not in move["open_valves"]
                for j, _ in enumerate(move["curr_valves"])
            ]
            for index, _ in enumerate(move["new_valves"]):
                if open_valves[index]:
                    # open valve
                    if move["new_valves"][index] in move["open_valves"]:
                        raise ValueError
                    move["open_valves"].append(move["new_valves"][index])
                    move["curr_pressure"] += valves[move["new_valves"][index]]["flow_rate"]
                else:
                    # move to valve
                    move["curr_valves"][index] = routes[f"{move['curr_valves'][index]},{move['new_valves'][index]}"][0]
            # add all new moves
            new_moves_list = [
                (
                    [move["new_valves"][index]]
                    if not open_valves[index]
                    else [valve for valve, _ in enumerate(valve_names) if valve not in move["open_valves"] and valve not in move["new_valves"]]
                )
                for index, valve in enumerate(move["new_valves"])
            ]
            new_queue.extend(
                [
                    {
                        "new_valves": list(new_valves),
                        "curr_valves": [*move["curr_valves"]],
                        "curr_pressure": move["curr_pressure"],
                        "sum_pressure": move["sum_pressure"],
                        "open_valves": [*move["open_valves"]],
                    }
                    for new_valves in itertools.product(*new_moves_list) if len(list(new_valves)) == len(set(list(new_valves)))
                ]
            )
        queue = [json.loads(i) for i in set(json.dumps(move, sort_keys=True) for move in new_queue)]  # filter out duplicate moves
        values = [
            move["curr_pressure"] * (30 - i)
            + move["sum_pressure"]
            + sum(
                [
                    valves[move["new_valves"][j]]["flow_rate"] * (30 - i - route_cost[move["curr_valves"][j], move["new_valves"][j]])
                    for j, _ in enumerate(move["curr_valves"])
                ]
            )
            for move in queue
        ]
        # only top n moves
        queue = [queue[i] for i in sorted(range(len(values)), key=lambda k: values[k], reverse=True)[:500]]
    print(np.max([item["sum_pressure"] for item in queue]))


T = TypeVar("T")


def flatten(l: List[List[T]]) -> List[T]:
    return [item for sublist in l for item in sublist]


def calculate_routes(valves: List[Dict[str, Any]]) -> Tuple[np.ndarray, Dict[str, List[int]]]:
    route_costs = np.zeros((len(valves), len(valves)))
    routes = {}
    for i, start_valve in enumerate(valves):
        for j, end_valve in islice(enumerate(valves), i + 1, None):
            queue: List[Dict[str, Any]] = [{"next": valve, "steps": [valve]} for valve in start_valve["connections"]]
            for step in range(1000):
                try:
                    index = [valve["next"] for valve in queue].index(j)
                    route_costs[i, j] = step + 1
                    route_costs[j, i] = step + 1
                    routes[f"{i},{j}"] = queue[index]["steps"]
                    routes[f"{j},{i}"] = [*list(reversed(queue[index]["steps"]))[1:], i]
                    break
                except ValueError:
                    pass
                queue = flatten(
                    [
                        [
                            {"next": next_valve, "steps": [*valve["steps"], next_valve]}
                            for next_valve in valves[valve["next"]]["connections"]
                        ]
                        for valve in queue
                    ]
                )
                queue = [move for move in queue if move["next"] != i and move["next"] not in move["steps"][:-1]]  # remove loop moves
                queue = list({move["next"]: move for move in queue}.values())  # filter out duplicate moves
    return route_costs, routes


if __name__ == "__main__":
    with open("input", "r") as f:
        main(f)
