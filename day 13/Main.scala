import scala.io.Source
import scala.collection.mutable.ArrayBuffer

enum Outcome:
  case RightOrder, WrongOrder, Undecided

class Element(var single_value: Boolean = false, var value: Int = 0, var childs: ArrayBuffer[Element] = ArrayBuffer(), var parent: Option[Element] = None, val divider: Boolean = false):
    def right_order(other: Element): Outcome =
        if this.single_value && other.single_value then
            if this.value < other.value then
                return Outcome.RightOrder
            else if this.value > other.value then
                return Outcome.WrongOrder
            else
                return Outcome.Undecided

        if !this.single_value && !other.single_value then
            var index = 0
            while true do
                if index < this.childs.length && index < other.childs.length then
                    val return_value = this.childs(index).right_order(other.childs(index))
                    if return_value == Outcome.Undecided then
                        index += 1
                    else
                        return return_value
                        
                else if this.childs.length > other.childs.length then
                    return Outcome.WrongOrder
                else if this.childs.length < other.childs.length then
                    return Outcome.RightOrder
                else
                    return Outcome.Undecided
        
        if this.single_value then
            // promote left value to list
            this.single_value = false
            this.childs += Element(true, this.value, ArrayBuffer(), Some(this), this.divider)
            val return_value = this.right_order(other)

            // undo promotion
            this.single_value = true
            this.childs = ArrayBuffer()
            return return_value
        else
            // promote right value to list
            other.single_value = false
            other.childs += Element(true, other.value, ArrayBuffer(), Some(other), this.divider)
            val return_value = this.right_order(other)

            // undo promotion
            other.single_value = true
            other.childs = ArrayBuffer()
            return return_value
        

@main def main() =
    val source = Source.fromFile("input")
    var elements: ArrayBuffer[Element] = ArrayBuffer()
    source.getLines().toArray.foreach { case (line) => 
        if line.length() != 0 then
            val element = Element()
            var currElement = element
            var index: Int = 0
            while index < line.length() - 1 do
                if line(index) == '[' then
                    currElement.single_value = false
                    currElement.childs += Element()
                    currElement.childs(currElement.childs.length - 1).parent = Some(currElement)
                    currElement = currElement.childs(currElement.childs.length - 1)
                    index += 1
                else if line(index) == ']' then
                    currElement = currElement.parent.get
                    index += 1
                else if line(index) != ',' then
                    val num = line.slice(index, line.length()).split(",")(0).split("]")(0).toInt
                    index += num.toString().length()
                    currElement.childs += Element(true, num, ArrayBuffer(), Some(currElement))
                else
                    index += 1
            elements += element
    }

    val count = elements.toArray.sliding(2, 2).zipWithIndex.map {case (Array(left, right), index) => {
        if (left.right_order(right) == Outcome.RightOrder) (index + 1) else 0
    }}.sum
    println(count)

    elements += ((Element(false, 0, ArrayBuffer(Element(false, 0, ArrayBuffer(Element(true, 2)))), None, true)))
    elements(elements.length-1).childs(0).parent = Some(elements(elements.length-1))
    elements(elements.length-1).childs(0).childs(0).parent = Some(elements(elements.length-1).childs(0))
    elements += ((Element(false, 0, ArrayBuffer(Element(false, 0, ArrayBuffer(Element(true, 6)))), None, true)))
    elements(elements.length-1).childs(0).parent = Some(elements(elements.length-1))
    elements(elements.length-1).childs(0).childs(0).parent = Some(elements(elements.length-1).childs(0))

    val sorted_indices = (0 until elements.length).toArray
    var swaps = 1
    while swaps != 0 do
        swaps = 0
        var index = 0
        while index < sorted_indices.length-1 do
            if elements(sorted_indices(index)).right_order(elements(sorted_indices(index+1))) == Outcome.WrongOrder then
                val temp = sorted_indices(index+1)
                sorted_indices(index+1) = sorted_indices(index)
                sorted_indices(index) = temp
                swaps += 1
            
            index += 1
    
    val distress_key = sorted_indices.zipWithIndex.filter{case(index, _) => elements(index).divider}.map{case(_, index) => index+1}.product
    println(distress_key)