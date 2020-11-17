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
                const videoId = "video_" + i;
                let video = "<video-js id=\"" + videoId + "\" class=\"vjs-default-skin\" controls preload=\"auto\" width=\"640\" height=\"268\"><source src=\"" + responseData[i]["url"] + "\"  type=\"application/x-mpegURL\"></video-js>";
                video += "<div class='btn-group'><a class='btn downvote' video_id=" + responseData[i]["id"] + "><i class=\"far fa-thumbs-down\"></i>" + responseData[i]["downvotes"] + "</a>";
                video += "<a class='btn upvote' video_id=" + responseData[i]["id"] + "><i class=\"far fa-thumbs-up\"></i>" + responseData[i]["upvotes"] + "</a></div>";
                video += "<h2>" + responseData[i]["title"] + "</h2><h3>" + responseData[i]["description"] + "</h3>";
                title.insertAdjacentHTML('afterend', video);
                videojs(videoId);
            }

            registerVoteSubmission();

        }

    }
}

function registerVoteSubmission() {
    const xhrUpvoteButtons = document.querySelectorAll('a.upvote');
    const xhrDownvoteButtons = document.querySelectorAll('a.downvote');

    for (let i = 0; i < xhrUpvoteButtons.length; i++) {
        xhrUpvoteButtons[i].addEventListener('click', (event) => {
            event.preventDefault();
            var votes = parseInt(event.target.textContent);
            votes++;
            event.target.textContent = votes.toString();
            const xhr = new XMLHttpRequest();
            xhr.open("post", "/api/votes", true);
            xhr.send();

        });
    }


    for (let i = 0; i < xhrDownvoteButtons.length; i++) {
        xhrDownvoteButtons[i].addEventListener('click', (event) => {
            event.preventDefault();
            var votes = parseInt(event.target.textContent);
            votes++;
            event.target.textContent = votes.toString();
            const xhr = new XMLHttpRequest();
            xhr.open("post", "/api/votes", true);
            xhr.send();

        });
    }


}

loadData();

