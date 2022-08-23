const NotesContract = artifacts.require("NoteContract");

module.exports = function (deployer) {
  deployer.deploy(NotesContract);
}