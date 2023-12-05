type
    Interval* = object
        min*, max*: float

proc initInterval*(min, max: float): Interval = Interval(min: min, max: max)

proc contains*(interval: Interval, val: float): bool = 
    interval.min <= val and val <= interval.max

proc surrounds*(interval: Interval, val: float): bool =
    interval.min < val and val < interval.max

proc clamp*(interval: Interval, val: float): float =
    if val < interval.min: interval.min
    elif val > interval.max: interval.max
    else: val

const empty* = initInterval(Inf, NegInf)
const universe* = initInterval(NegInf, Inf)
