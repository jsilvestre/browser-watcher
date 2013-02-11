num = 0;

test = () ->
    console.log("Test n°" + num)
    num++

setInterval(test, 5000)