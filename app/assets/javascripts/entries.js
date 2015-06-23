// accordion for category tree
$(function(){
    $("#menu-tree-t").click(function(){
        $("#categories").slideToggle('slow');
		$("#menu-tree-t").find(".fa").toggleClass("fa-chevron-down").toggleClass("fa-chevron-up");
    });
});

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
function word_cloud(){
	var natto_results = gon.results;
	console.log(natto_results);
	natto_results.splice(1000);

	var h = 800;
	var w = 800;
	var random = d3.random.irwinHall(2);
	var countMax = d3.max(natto_results, function(d){ return d[1];} );
	var sizeScale = d3.scale.linear().domain([0, countMax]).range([10, 150]);
	var colorScale = d3.scale.category20();
	var words = natto_results.map(function(d) {
		return {
		text: d[0],
		size: sizeScale(d[1]) //頻出カウントを文字サイズに反映
		};
	});
	console.log(words);


	d3.layout.cloud().size([w, h])
		.words(words)
		.rotate(function() { return Math.round(1-random()) *60; }) //ランダムに文字を90度回転
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

