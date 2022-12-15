package main

import (
	"bufio"
	"log"
	"math"
	"os"
	"strconv"
	"strings"
)

type Position struct {
	x int
	y int
}

func (l *Position) distance(r *Position) int {
	return int(math.Abs(float64(l.x-r.x)) + math.Abs(float64(l.y-r.y)))
}

type Sensor struct {
	sensor          Position
	beacon          Position
	beacon_distance int
}

func (sensor *Sensor) boarder() []Position {
	count := 4 * (sensor.beacon_distance + 1)
	boarder := make([]Position, count)

	for i := 0; i < count/4; i++ {
		boarder[i] = Position{sensor.sensor.x + i, sensor.sensor.y - (sensor.beacon_distance + 1) + i}
		boarder[i+count/4] = Position{sensor.sensor.x - i, sensor.sensor.y + (sensor.beacon_distance + 1) - i}
		boarder[i+count/2] = Position{sensor.sensor.x + (sensor.beacon_distance + 1) - i, sensor.sensor.y - i}
		boarder[i+3*count/4] = Position{sensor.sensor.x - (sensor.beacon_distance + 1) + i, sensor.sensor.y + i}
	}
	return boarder
}

type Board struct {
	sensors []Sensor
}

func (board *Board) cannot_contain_beacon(position Position) bool {
	cannot_contain_beacon := false
	for i := range board.sensors {
		if position.distance(&board.sensors[i].sensor) <= board.sensors[i].beacon_distance {
			cannot_contain_beacon = true
		}
		if position == board.sensors[i].beacon {
			return false
		}
	}
	return cannot_contain_beacon
}

func (board *Board) add_sensor(sensor string) {
	sensor_x, _ := strconv.Atoi(strings.Split(sensor[12:], ",")[0])
	sensor_y, _ := strconv.Atoi(strings.Split(sensor[16+len(strconv.Itoa(sensor_x)):], ":")[0])
	start := 41 + len(strconv.Itoa(sensor_x)) + len(strconv.Itoa(sensor_y))
	beacon_x, _ := strconv.Atoi(strings.Split(sensor[start:], ",")[0])
	beacon_y, _ := strconv.Atoi(sensor[start+4+len(strconv.Itoa(beacon_x)):])
	sensor_pos := Position{sensor_x, sensor_y}
	beacon_pos := Position{beacon_x, beacon_y}
	board.sensors = append(board.sensors, Sensor{sensor_pos, beacon_pos, beacon_pos.distance(&sensor_pos)})
}

func main() {
	file, err := os.Open("input")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	var board = Board{[]Sensor{}}

	for scanner.Scan() {
		line := scanner.Text()
		board.add_sensor(line)
	}
	line := 2000000
	curr_pos := -3778742
	end := 3778742 * 4
	count := 0

	for curr_pos < end {
		if board.cannot_contain_beacon(Position{curr_pos, line}) {
			count++
		}
		curr_pos++
	}

	println(count)

	for i := range board.sensors {
		boarder := board.sensors[i].boarder()
		for j := range boarder {
			if boarder[j].x <= 4000000 && boarder[j].x >= 0 && boarder[j].y <= 4000000 && boarder[j].y >= 0 && !board.cannot_contain_beacon(Position{boarder[j].x, boarder[j].y}) {
				println(int64(boarder[j].x)*4000000 + int64(boarder[j].y))
				return
			}
		}
	}
}
