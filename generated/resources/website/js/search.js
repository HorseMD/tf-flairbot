function updateFlairList() {
    var txtbox = document.getElementById("search");
    var count = Object.keys(names).length;
    for(var i=0; i<count; i++) {
        if(names[i].toLowerCase().indexOf(txtbox.value.toLowerCase().replace(/\s/g, '')) <= -1) {
            document.getElementById(i).style.display = "none";
        } else {
            document.getElementById(i).style.display = "inline-block";
        }
    }
}

// when the user hovers over a flair, it should display a tooltip with the name.
function onFlairHover(flair, event) {
    var tt = document.getElementById("tooltip");
    tt.innerHTML = names[flair.id];

    var targetX = event.clientX + window.pageXOffset - tt.clientWidth / 2;
    var targetY = event.clientY + window.pageYOffset + 5;

    tt.style.display = "inline-block";
    tt.style.left = targetX + "px";
    tt.style.top  = targetY + "px";
}

// when the user isn't mousing-over a flair, the tooltip should be invisible.
function onMouseAway() {
    var tt = document.getElementById("tooltip");
    tt.style.display = "none";
}

document.getElementById("flairs").addEventListener("mousemove", function(event) {
    if(event.target.tagName.toLowerCase() == 'li') {
        onFlairHover(event.target, event);
    } else {
        onMouseAway();
    }
});
document.getElementById("search").addEventListener("input", updateFlairList, false);
