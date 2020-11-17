function loadData() {

    const xhr = new XMLHttpRequest();
    xhr.open("get", "/api/videos", true);
    xhr.send();

    xhr.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            const response = JSON.parse(this.responseText);
            const responseData = response.data;
            console.log("DATA", response.data);
            const x = document.getElementById("loader");

            let title = document.getElementById('title');
            x.style.display = "none";
            for (let i = 0; i < responseData.length; i++) {
                const videoId="video_"+i;
                let video = "<video-js id=\""+ videoId +"\" class=\"vjs-default-skin\" controls preload=\"auto\" width=\"640\" height=\"268\"><source src=\""+ responseData[i]["url"] +"\"  type=\"application/x-mpegURL\"></video-js>";
                video += "<h2>"+ responseData[i]["title"] +"</h2><h3>"+ responseData[i]["description"] +"</h3>";
                video += "<div class='buttons'><button class='downvote' video_id="+ responseData[i]["id"] +"><i class=\"far thumbs-down\"></i>"+ responseData[i]["id"]["downvotes"] +"</button>";
                video += "<button class='upvote' video_id="+ responseData[i]["id"] +"><i class=\"far thumbs-up\"></i>"+ responseData[i]["id"]["upvotes"] +"</button></div>";
                title.insertAdjacentHTML('afterend', video);
                videojs(videoId);
            }

            registerVoteSubmission();

        }

    }
}

function registerVoteSubmission() {
    const xhrButtonUpvote = document.querySelector('.upvote');
    const xhrButtonDownvote = document.querySelector('.downvote');

    xhrButtonUpvote.addEventListener('click', (event) => {
        var votes = parseInt(event.target.textContent);
        votes++
        event.target.innerHTML = votes.toString();
        const xhr = new XMLHttpRequest();
        xhr.open("post", "/api/votes", true);
        xhr.send();

    });

    xhrButtonDownvote.addEventListener('click', (event) => {
        var votes = parseInt(event.target.textContent);
        votes++
        event.target.innerHTML = votes.toString();
        const xhr = new XMLHttpRequest();
        xhr.open("post", "/api/votes", true);
        xhr.send();
    });


}

loadData();

