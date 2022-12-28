const TOPIC = '**FIXME**';
const ENDPOINT = '**FIXME**';
const message = {/* FIXME */};
const pubsubMessage = JSON.stringify(message);
console.log(`gcloud pubsub topics publish ${TOPIC} --message='${pubsubMessage}'`);
const httpMessage = JSON.stringify({message: {data: Buffer.from(JSON.stringify(message)).toString('base64')}});
console.log(`curl -v -X POST -H 'Content-type:application/json' --data '${httpMessage}' ${ENDPOINT}`);
