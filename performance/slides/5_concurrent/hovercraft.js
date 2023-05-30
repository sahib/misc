// This small JS snippet turns all .example blocks into clickable links
// (which lead to this repositories Github)
var exampleElems = document.querySelectorAll('.example');
for (var i = 0; i < exampleElems.length; ++i) {
    var item = exampleElems[i];

    exampleName = item.innerHTML.replace('Example: ', '').trim()
    item.innerHTML = '<a style="color: #fff" href="https://github.com/sahib/misc/tree/master/performance/' + exampleName + '">' + item.innerHTML + '</a>';
}

// This snippet counts the average time spend on each slide. A slide change
// is registered by looking at the fragment part of the URL. For debugging
// reasons we also maintain a map of slide-name to time-spent-in-ms values.
//
// This metric is useful to adjust the speed of your presentation. If you know
// that you have e.g. 4h for presentation and have 40 slides, then you can roughly
// spend 6m per slide. If you take longer you should probably speed up.
//
// For now this metric is only shown in the console. Showing it in the presenter console
// turned out to be complicated as getElementById('controls') for some reason returns
// null here but works in the interactive console.
//
// If you want to reset the count then just do 'perSlideTiming = new Map();'
var perSlideTiming = new Map();
var lastSlideName = ''
var lastTimestamp = Date.now()

window.addEventListener('hashchange', function () {
    fragment = window.location.hash
    if (fragment.length <= 2) {
        return
    }

    fragment = fragment.substring(2)
    newTimestamp = Date.now()
    if (lastSlideName != '') {
        perSlideTiming.set(lastSlideName, newTimestamp - lastTimestamp)
    }

    lastSlideName = fragment
    lastTimestamp = newTimestamp

    if (perSlideTiming.size > 0) {
        var averagePerSlide = 0
        for (const value of perSlideTiming.values()) {
            averagePerSlide += value
        }

        averagePerSlide /= perSlideTiming.size
        averagePerSlide = Math.round(averagePerSlide/1000)
        console.log("Average time per slide: " + averagePerSlide + "s")
        // var perSlideNode = undefined;
        // var lastControlNode = undefined;
        // var controls = document.getElementById('controls');
        // console.log("Found controls" + controls + " " + controls.length);
        // for (var i = 0; i < controls.length; ++i) {
        //     var item = controls[i];
        //     if (item.id == "per-slide-timer") {
        //         perSlideNode = item;
        //     }

        //     console.log("Node" + item);
        //     lastControlNode = item;
        // }

        // if (perSlideNode == undefined) {
        //     perSlideNode = document.createElement('div');
        //     perSlideNode.id = "per-slide-timer";
        //     console.log('creating perSlideNode elem');
        //     lastControlNode.insertBefore(perSlideNode);
        // }

        // console.log('adjusting perSlideNode');
        // perSlideNode.innerHTML = averagePerSlide + "s";
    }
})


