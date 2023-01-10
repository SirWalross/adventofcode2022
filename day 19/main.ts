import * as fs from 'fs';

let blueprints = fs.readFileSync('input').toString('utf-8').split("\n").map((value) => {
    let robots = value.split(': ')[1].split('. ');
    return [
        [parseInt(robots[0].split(' ')[4]), 0, 0, 0],
        [parseInt(robots[1].split(' ')[4]), 0, 0, 0],
        [parseInt(robots[2].split(' ')[4]), parseInt(robots[2].split(' ')[7]), 0, 0],
        [parseInt(robots[3].split(' ')[4]), 0, parseInt(robots[3].split(' ')[7]), 0]
    ];
});

let quality_levels = blueprints.map((blueprint, blueprint_index) => {
    let queue = [{ "resources": [0, 0, 0, 0], "robots": [1, 0, 0, 0], "robots_able_to_produce": [0, 0, 0, 0] }];
    for (var i = 0; i < 32; i++) {
        queue.forEach((item) => { item["resources"] = item["resources"].map((resource, index) => resource + item["robots"][index]) });
        let new_queue = queue;
        // add new queue item for each option
        queue.forEach((item) => {
            for (const [robot_index, robot_cost] of blueprint.entries()) {
                if (item["resources"].every((resource, index) => (resource - item.robots[index]) >= robot_cost[index])) {
                    if (blueprint.map(value => value[robot_index]).every(value => item.robots[robot_index] >= value && robot_index != 3) || item.robots_able_to_produce[robot_index] == 1) {
                        // no need to produce another robot
                        continue;
                    }
                    new_queue.push(
                        {
                            "resources": item["resources"].map((resource, index) => resource - robot_cost[index]),
                            "robots": item["robots"].map((robot_count, index) => (index != robot_index) ? robot_count : (robot_count + 1)),
                            "robots_able_to_produce": [0, 0, 0, 0]
                        }
                    );
                    item.robots_able_to_produce[robot_index] = 1;
                } else {
                    item.robots_able_to_produce[robot_index] = 0;
                }
            };
        });
        let max_geodes_producable = new_queue.map(value => value.resources[3] + (value.robots[3]) * (31 - i) + (31 - i) * (32 - i) / 2);
        let max_geode_producable = arrayMax(max_geodes_producable);
        let max_geodes_robots_producable = new_queue.map(value => value.robots[3] + (value.resources[2] + (value.robots[2]) * (31 - i) + (31 - i) * (32 - i) / 2) / blueprint[3][2]);
        if (i < 25) {
            queue = new_queue.filter((value, index) => max_geodes_producable[index] >= max_geode_producable - 15 && max_geodes_robots_producable[index] >= 1.0 && (i < 19 || value.resources[2] != 0));
        } else {
            queue = new_queue.filter((value, index) => max_geodes_producable[index] >= max_geode_producable * 0.8 && max_geodes_robots_producable[index] >= 1.0 && (i < 19 || value.resources[2] != 0));
        }
        // queue = new_queue;
        console.log("%d: %d, %d", i, queue.length, arrayMax(queue.map(value => value.resources[3])));
    }
    console.log("For blueprint %d got %d geodes", blueprint_index + 1, arrayMax(queue.map(value => value.resources[3])));
    return arrayMax(queue.map(value => value.resources[3]));
});
console.log("Product of quality levels: %d", quality_levels.reduce((partialProduct, a) => partialProduct * a, 1));

function arrayMax(arr) {
    var len = arr.length, max = 0;
    while (len--) {
        if (arr[len] > max) {
            max = arr[len];
        }
    }
    return max;
};