// fadein and follow attributes for the link to document top
$(function(){
    $(window).scroll(function(){
        var now = $(this).scrollTop();
        if(now>500){
            $("#fade_and_follow").fadeIn();
        }else{
            $("#fade_and_follow").fadeOut();
        }
    });
    $("#move_top").click(function(){
        $("html,body").animate({scrollTop:0},"slow");
    });
});

// scattering item blocks like tiles
$(function(){
    $('#cont').masonry({
        itemSelector : '.item',
		isAnimated: true,
		//isFitWidth: true,
		isRTL: false,
		gutterWidth: 0
    });
});

// infinite scroll
$(function(){

    var container = $('#cont');
	
    /*
      container.imagesLoaded(function(){
      $(container).masonry({
      itemSelector: '.item'
      //columnWidth: 10
	  });
	  });
    */
	
    container.infinitescroll({
        navSelector  : 'div#loading-area nav.pagination',
        nextSelector : 'div#loading-area nav.pagination .next a',
        itemSelector : '.item',
        animate      : true,
        //loading      : { finishedMsg: '<i class="fa fa-spinner fa-5x fa-spin"></i>'}
    },
							 function(newElements){
								 var newElems = $(newElements).css({opacity: 0});
								 newElems.imagesLoaded(function(){
									 newElems.animate({opacity: 1});
									 //.css('text-align','center')
									 //.css('top','50%');
									 container.masonry('appended', newElems, true);
								 });
							 });
});



// for clipped entries analysis
function word_cloud(num){
	var data = gon.results.slice(-num);
	//console.log(natto_results);

	var h = 800;
	var w = 800;
	var random = d3.random.irwinHall(2);
	var countMax = d3.max(data, function(d){ return d[1];} );
	var sizeScale = d3.scale.linear().domain([0, countMax]).range([10, 150]);
	var colorScale = d3.scale.category20();
	var words = data.map(function(d) {
		return {
		text: d[0],
		size: sizeScale(d[1]) //頻出カウントを文字サイズに反映
		};
	});
	//console.log(words);


	d3.layout.cloud().size([w, h])
		.words(words)
		.rotate(function() { return Math.round(1-random()) *33; }) //ランダムに文字を90度回転
		.font("Impact")
		.fontSize(function(d) { return d.size; })
		.on("end", draw)
		.start();

	//wordcloud 描画
	function draw(words) {
		d3.select("div#word_cloud")
		.append("svg")
		.attr({
			"width": w,
			"height": h
		})
		.append("g")
		.attr("transform", "translate(150,150)")
		.selectAll("text")
		.data(words)
		.enter()
		.append("text")
		.style({
			"font-family": "Impact",
			"font-size":function(d) { return d.size + "px"; },
			"fill": function(d, i) { return colorScale(i); }
		})
		.attr({
			"text-anchor":"middle",
			"transform": function(d) {
				return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
			}
		})
		.text(function(d) { return d.text; });
	}
};


// for bar chart of word frequency
//d3.tsv("data.tsv", type, function(error, data) {
function bar_chart(num) {
	var margin = {top: 20, right: 20, bottom: 30, left: 40},
		width = 960 - margin.left - margin.right,
		height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
		.rangeRoundBands([0, width], .1);

	var y = d3.scale.linear()
		.range([height, 0]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom");

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left")
		.ticks(10, "%");

	//var svg = d3.select("body").append("svg")
	var svg = d3.select("div#barchart").append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


	//if (error) throw error;

	var data = gon.results.slice(-num);
	x.domain(data.map(function(d) { return d[0]; }));
	y.domain([0, d3.max(data, function(d) { return d[1]; })]);

	svg.append("g")
		.attr("class", "x axis")
		.attr("transform", "translate(0," + height + ")")
		.call(xAxis);

	svg.append("g")
		.attr("class", "y axis")
		.call(yAxis)
		.append("text")
		.attr("transform", "rotate(-90)")
		.attr("y", 6)
		.attr("dy", ".71em")
		.style("text-anchor", "end")
		.text("Frequency");

	svg.selectAll(".bar")
		.data(data)
		.enter().append("rect")
		.attr("class", "bar")
		.attr("x", function(d) { return x(d[0]); })
		.attr("width", x.rangeBand())
		.attr("y", function(d) { return y(d[1]); })
		.attr("height", function(d) { return height - y(d[1]); });

	function type(d) {
		d[1] = +d[1];
		return d;
	}

};

