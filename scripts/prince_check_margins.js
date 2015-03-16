Prince.trackBoxes = true;
Prince.addEventListener("complete", check, false);

function check()
{
    var tables = document.getElementsByTagName("table");

    for (var i = 0; i < tables.length; ++i)
    {
        var bs = tables[i].getPrinceBoxes();

        for (var j = 0; j < bs.length; ++j)
        {
            if (bs[j].w > 5.1*73)
            {
                console.log("table is too wide on page "+bs[j].pageNum);
            }
        }
    }
}
