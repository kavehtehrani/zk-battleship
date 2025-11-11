const app = document.getElementById("app");
app.innerHTML = `
  <div style="font-family: sans-serif; padding: 16px">
    <h1>zk-battleship</h1>
    <p>Local demo UI. Steps:</p>
    <ol>
      <li>Compile circuits in zk-battleship/circuit</li>
      <li>Generate verifiers and deploy with Hardhat</li>
      <li>Create a game (board proof + commitment)</li>
      <li>Submit shots (shot proof per turn)</li>
    </ol>
  </div>
`;

const app = document.getElementById('app');
app.innerHTML = `
  <div style="font-family: system-ui, sans-serif; padding: 24px; max-width: 900px; margin: 0 auto;">
    <h1>zk-battleship</h1>
    <p>Local demo UI. Steps:</p>
    <ol>
      <li>Choose config (width, height, fleet).</li>
      <li>Place ships and generate board proof via Noir.</li>
      <li>Deploy and interact with Battleship contract.</li>
      <li>Take turns: generate shot proofs and submit.</li>
    </ol>
    <p>Integration wiring to be added.</p>
  </div>
`;


