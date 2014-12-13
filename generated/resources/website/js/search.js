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

document.getElementById("search").addEventListener("input", updateFlairList, false);
