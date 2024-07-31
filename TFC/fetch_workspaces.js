const https = require("https");

function fetchAllWorkspaces(apiUrl, token, callback) {
  let page = 1;
  let allWorkspaces = [];

  function fetchPage() {
    const url = `${apiUrl}&page[number]=${page}`;
    const options = {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    };

    https
      .get(url, options, (res) => {
        let data = "";

        res.on("data", (chunk) => {
          data += chunk;
        });

        res.on("end", () => {
          const response = JSON.parse(data);
          if (!response.data || response.data.length === 0) {
            callback(allWorkspaces);
            return;
          }
          allWorkspaces = allWorkspaces.concat(response.data);
          page++;
          fetchPage();
        });
      })
      .on("error", (e) => {
        console.error(`Got error: ${e.message}`);
        callback(allWorkspaces);
      });
  }

  fetchPage();
}

const [apiUrl, token] = process.argv.slice(2);
fetchAllWorkspaces(apiUrl, token, (workspaces) => {
  const result = { workspaces: JSON.stringify(workspaces) };
  console.log(JSON.stringify(result));
});
