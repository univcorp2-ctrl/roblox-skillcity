--!strict

local MathTasks = {}

export type Task = {
    prompt: string,
    answer: number,
    context: string,
}

local function money(value: number): string
    return string.format("$%d", value)
end

function MathTasks.generate(rng: Random): Task
    local kind = rng:NextInteger(1, 3)
    if kind == 1 then
        local price = rng:NextInteger(4, 18)
        local qty = rng:NextInteger(2, 5)
        return {
            prompt = string.format("%s × %d = ?", money(price), qty),
            answer = price * qty,
            context = "market_total",
        }
    elseif kind == 2 then
        local price = rng:NextInteger(6, 34)
        local paid = math.ceil((price + rng:NextInteger(5, 30)) / 5) * 5
        return {
            prompt = string.format("%s paid for %s. Change?", money(paid), money(price)),
            answer = paid - price,
            context = "change",
        }
    else
        local distance = rng:NextInteger(2, 9)
        local minutesPerKm = rng:NextInteger(3, 8)
        return {
            prompt = string.format("%d km × %d min/km = ? min", distance, minutesPerKm),
            answer = distance * minutesPerKm,
            context = "route_time",
        }
    end
end

return MathTasks
