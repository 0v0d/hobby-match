/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

initializeApp();

export const onLikeCreate = onDocumentCreated(
    {document: "likes/{likeId}", region: "asia-northeast1"},

    async(event) => {
        const like = event.data?.data();
        if(!like) return;
        const from = like.fromUserId as string;
        const to = like.toUserId as string;
        
        const db = getFirestore();
        const reverseLikeSnap = await db.doc(`likes/${to}_${from}`).get();
        //相互いいねでなければ何もしない
        if (!reverseLikeSnap.exists) return;

        const matchId = [from,to].sort().join("_");

        try {
            await db.doc(`matches/${matchId}`).create(
                {
                    users:[from,to].sort(),
                    createdAt: new Date(),
                }
            )
        } catch(e) {
            // 既に存在 (二重起動) → 無視
            console.log(`match ${matchId} already exists`);
        }
    }
)