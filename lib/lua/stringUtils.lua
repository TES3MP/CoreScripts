function prefixZeroes(inputString, lengthDesired)

    local length = string.len(inputString)

    while length < lengthDesired do
        inputString = "0" .. inputString
        length = length + 1
    end

    return inputString
end
